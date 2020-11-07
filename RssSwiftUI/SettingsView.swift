//
//  SettingsView.swift
//  RssSwiftUI
//
//  Created by Dmitry Kocherovets on 06.11.2020.
//

import SwiftUI
import DITranquillity
import RedSwift
import ReduxVM
import Combine
import DeclarativeTVC
import RssState

var qq = 0

struct SettingsView: View {

    struct RssFeed {
        let url: String
        let title: String
    }
    static let feeds = [
        RssFeed(url: "https://www.nasa.gov/rss/dyn/breaking_news.rss", title: "Add NASA breaking news"),
        RssFeed(url: "https://www.nasa.gov/rss/dyn/educationnews.rss", title: "Add NASA education news"),
        RssFeed(url: "https://www.smithsonianmag.com/rss/photos/", title: "Add photos feed"),
        RssFeed(url: "https://www.washingtontimes.com/rss/headlines/news/local/", title: "Washington Times: Local"),
        RssFeed(url: "https://www.washingtontimes.com/rss/headlines/news/politics/", title: "Washington Times: Politics"),
    ]

    struct Props: SwiftUIProperties {
        var updateInterval = "0"
        var updateIntervalCommand = CommandWith<String> { value in }
        var intervalEditing = false
        var addSourceFromClipboardCommand = Command { }
        struct Source: Hashable {
            var title: String
            var isActive: Bool
            var valueChangedCommand: Command
            var removeCommand: Command
        }
        var sources: [Source] = [
            Source(
                title: "source title",
                isActive: true,
                valueChangedCommand: Command { },
                removeCommand: Command { }
            )
        ]
        struct AvailableSource: Hashable {
            var title: String
            var addCommand: Command
        }
        var availableSources: [AvailableSource] = [
            AvailableSource(
                title: "available source",
                addCommand: Command { }
            )
        ]
    }

    class Presenter: SwiftUIPresenter<AppState, Props> {

        required init(store: Store<AppState>) {
            super.init(store: store)
            qq += 1
            print("qq = \(qq)")
        }

        deinit {
            print("deinit")
            qq -= 1
            print("qq = \(qq)")
        }

        override func reaction(for box: StateBox<AppState>) -> ReactionToState
        {
            box.lastAction is UISettings ? .props : .none
        }

        override func props(for box: StateBox<AppState>, trunk: Trunk) -> Props {
            Props(
                updateInterval: props.intervalEditing ? props.updateInterval : String(box.state.settings.updateIntervalSeconds),
                updateIntervalCommand: CommandWith<String> { value in
                    trunk.dispatch(SettingsState.SetUpdateIntervalAction(seconds: Int(value) ?? 300,
                                                                         fromDB: false))
                },
                addSourceFromClipboardCommand: Command {
                    if let url = UIPasteboard.general.string?.trimmingCharacters(in: .whitespaces) {
                        trunk.dispatch(SettingsState.AddSourcesAction(
                            sources: [SettingsState.AddSourcesAction.Info(url: url,
                                                                          active: true)],
                            fromDB: false))
                    }
                },
                sources: box.state.settings.sources.keys.sorted()
                    .map { url in
                        let isActive = box.state.settings.sources[url] == true
                        return Props.Source(
                            title: url,
                            isActive: isActive,
                            valueChangedCommand: Command {
                                trunk.dispatch(SettingsState.SetSourceActivityAction(sourceURL: url,
                                                                                     activity: !isActive))
                            },
                            removeCommand: Command {
                                trunk.dispatch(SettingsState.RemoveSourceAction(sourceURL: url))
                            })
                },
                availableSources: feeds
                    .filter { availableSource in
                        box.state.settings.sources.keys.first(where: { $0 == availableSource.url }) == nil
                    }
                    .map { feed in
                        Props.AvailableSource(
                            title: feed.title,
                            addCommand: Command {
                                trunk.dispatch(SettingsState.AddSourcesAction(
                                    sources: [SettingsState.AddSourcesAction.Info(url: feed.url,
                                                                                  active: true)],
                                    fromDB: false))
                            }
                        )
                }
            )
        }
    }

    var body: some View {
        Form {
            Section(header: Text("General").font(.largeTitle)) {
                HStack {
                    Text("Update news interval in seconds")
                    Spacer()
                    TextField("", text: $presenter.props.updateInterval,
                              onEditingChanged: { editing in presenter.props.intervalEditing = editing },
                              onCommit: { props.updateIntervalCommand.perform(with: presenter.props.updateInterval) }
                    )
                        .frame(width: 50)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
            Section(header: Text("Sources").font(.largeTitle)) {
                List {
                    ForEach(props.sources, id: \.self) { source in
                        Toggle(isOn: Binding(get: { source.isActive },
                                             set: { _, _ in source.valueChangedCommand.perform() }),
                               label: { Text(source.title) })
                    }
                        .onDelete(perform: removeSource)
                }
                HStack {
                    Spacer()
                    Button(action: { props.addSourceFromClipboardCommand.perform() },
                           label: { Text("Add source from clipboard") })
                    Spacer()
                }
                List {
                    ForEach(props.availableSources, id: \.self) { source in
                        HStack {
                            Spacer()
                            Button(action: { source.addCommand.perform() },
                                   label: { Text(source.title) })
                            Spacer()
                        }
                    }
                }
            }
        }
            .onAppear() { presenter.subscribe() }
            .onDisappear { presenter.unsubscribe() }
    }

    func removeSource(at offsets: IndexSet) {
        if let index = offsets.first {
            props.sources[index].removeCommand.perform()
        }
    }

    init(presenter: Presenter? = nil) {
        _presenter = StateObject(wrappedValue: presenter ?? Presenter(store: store))
    }

    @StateObject var presenter: Presenter// = Presenter(store: store)
    var props: Props { testProps ?? presenter.props }
    var testProps: Props? = nil
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
