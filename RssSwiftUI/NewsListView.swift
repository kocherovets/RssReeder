//
//  NewsListView.swift
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

struct NewsListView: View {

    struct Props: SwiftUIProperties {
        var leftBarButtonImageName = "star"
        var leftBarButtonTintColor = Color.blue
        var showsStarredOnlyCommand = Command { }
        var rightBarButtonImageName = "eye"
        var changeViewModeCommand = Command { }
        var hideBody = false
        var days: [NewsState.DayArticles] = [
            NewsState.DayArticles(
                date: Date(),
                articles: [
                    NewsState.Article(
                        source: "www.washingtontimes.com stories: Politics",
                        guid: "https://www.washingtontimes.com/news/2020/nov/6/mark-meadows-tests-positive-coronavirus-reports/?utm_source=RSS_Feed&utm_medium=RSS",
                        title: "Mark Meadows tests positive for coronavirus: Reports",
                        body: "WASHINGTON &mdash; President Donald Trump\'s chief of staff Mark Meadows has been diagnosed with the coronavirus as the nation sets daily records for confirmed cases for the pandemic. Two senior administration officials confirmed Friday that Meadows had tested positive for the virus, which has killed more than 236,000 Americans so ...",
                        time: Date(),
                        imageURL: "https://twt-thumbs.washtimes.com/media/image/2020/10/26/Trump_92332.jpg-658e8_s1440x960.jpg?f72536d07237fdd262042ae8f5e6e6de3b865f3c",
                        unread: true,
                        starred: false)])
        ]
        var selectCommand = CommandWith<NewsState.Article> { article in }
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

        var uuid = UUID()

        override func onInit(state: AppState, trunk: Trunk)
        {
            if state.news[uuid] == nil
                {
                trunk.dispatch(NewsState.AddNewsStateAction(newsUUID: uuid))
            }
        }

        override func reaction(for box: StateBox<AppState>) -> ReactionToState
        {
            box.lastAction is UINews ? .props : .none
        }

        override func props(for box: StateBox<AppState>, trunk: Trunk) -> Props {

            guard let news = box.state.news[uuid] else { return Props() }

            return Props(
                leftBarButtonImageName: news.showsStarredOnly ? "star.fill" : "star",
                leftBarButtonTintColor: news.showsStarredOnly ? Color(red: 1, green: 204.0 / 255.0, blue: 0) : Color.blue,
                showsStarredOnlyCommand: Command {
                    trunk.dispatch(NewsState.ShowsOnlyStarredAction(newsUUID: self.uuid, value: !news.showsStarredOnly))
                },
                rightBarButtonImageName: news.hideBody ? "eye.slash" : "eye",
                changeViewModeCommand: Command {
                    trunk.dispatch(NewsState.SetHideBodyAction(newsUUID: self.uuid, value: !news.hideBody))
                },
                hideBody: news.hideBody,
                days: news.days,
                selectCommand: CommandWith<NewsState.Article> { article in
                    trunk.dispatch(NewsState.SelectNewsAction(newsUUID: self.uuid,
                                                              article: article))
                }
            )
        }
    }

    var headerDateFormatter: DateFormatter = {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, dd MMMM yyyy"
        return dateFormatter
    }()

    var dateFormatter: DateFormatter = {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter
    }()

    var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                LazyVStack(spacing: 3, pinnedViews: [.sectionHeaders]) {
                    ForEach(props.days, id: \.self) { day in
                        Section(header: headerView(title: headerDateFormatter.string(from: day.date)),
                                content: {
                                    ForEach(day.articles, id: \.self) { article in
                                        NavigationLink(destination: ArticleView())
                                        {
                                            articleRow(source: article.source.uppercased(),
                                                       title: article.title,
                                                       body: article.body,
                                                       hideBody: props.hideBody,
                                                       time: dateFormatter.string(from: article.time),
                                                       imageURL: article.imageURL,
                                                       unread: article.unread,
                                                       starred: article.starred)
                                        }
                                            .simultaneousGesture(TapGesture().onEnded {
                                                                     presenter.freezed = true
                                                                     props.selectCommand.perform(with: article)
                                                                 })
                                    }
                                })
                    }
                }.id(UUID())
            }
                .onAppear() {
                    presenter.freezed = false
                }
                .navigationBarTitle("", displayMode: .inline)
                .navigationBarItems(
                    leading: Button(action: { props.showsStarredOnlyCommand.perform() },
                                    label: {
                                        Image(systemName: props.leftBarButtonImageName)
                                            .foregroundColor(Color(red: 1, green: 204.0 / 255.0, blue: 0))
                                    }),
                    trailing: Button(action: { props.changeViewModeCommand.perform() },
                                     label: { Image(systemName: props.rightBarButtonImageName) }))
        }
            .onAppear() {
                presenter.subscribe()

            }
            .onDisappear {
                presenter.unsubscribe()

        }
    }

    func headerView(title: String) -> some View {
        HStack {
            Text(title)
                .font(.caption)
            Spacer()
        }
            .padding([.leading, .trailing], 16)
            .padding([.top, .bottom], 5)
            .background(Color(red: 0.9, green: 0.9, blue: 0.9))
    }

    func articleRow(source: String,
                    title: String,
                    body: String,
                    hideBody: Bool,
                    time: String,
                    imageURL: String,
                    unread: Bool,
                    starred: Bool) -> some View {
        VStack {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    HStack {
                        Group {
                            if starred {
                                Image(systemName: "star.fill")
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(Color(red: 1, green: 204.0 / 255.0, blue: 0))
                                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0.5, trailing: 5))
                            }
                            else {
                                EmptyView()
                            }
                        }
                        Text(source)
                            .font(.callout)
                            .foregroundColor(Color(red: 0.8, green: 0.8, blue: 0.8))
                            .padding([.bottom], 1)
                    }
                    Text(title)
                        .font(.callout)
                        .bold()
                        .foregroundColor(unread ? Color(UIColor.black) : Color(UIColor.lightGray))
                        .padding([.bottom], 1)
                    Group {
                        if hideBody {
                            EmptyView()
                        } else {
                            Text(body)
                                .font(.callout)
                                .foregroundColor(unread ? Color(UIColor.darkGray) : Color(UIColor.lightGray))
                                .padding([.bottom], 1)
                                .lineLimit(3)
                        }
                    }
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text(time)
                        .font(.callout)
                        .foregroundColor(Color.black)
                    RemoteImage(url: imageURL)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                }
                    .frame(width: 76)
            }
                .padding([.leading, .trailing], 16)
                .padding([.top, .bottom], 5)
                .background(Color.white)
            Divider()
                .padding([.leading], 16)
        }
    }

    init(presenter: Presenter? = nil) {
        _presenter = StateObject(wrappedValue: presenter ?? Presenter(store: store))
    }

    @StateObject var presenter: Presenter// = Presenter(store: store)
    var props: Props { testProps ?? presenter.props }
    var testProps: Props? = nil
}

struct NewsListView_Previews: PreviewProvider {
    static var previews: some View {
        NewsListView()
    }
}

struct RemoteImage: View {
    private enum LoadState {
        case loading, success, failure
    }

    private class Loader: ObservableObject {
        var data = Data()
        var state = LoadState.loading

        init(url: String) {
            guard let parsedURL = URL(string: url) else {
//                fatalError("Invalid URL: \(url)")
                return
            }

            URLSession.shared.dataTask(with: parsedURL) { data, response, error in
                if let data = data, data.count > 0 {
                    self.data = data
                    self.state = .success
                } else {
                    self.state = .failure
                }

                DispatchQueue.main.async {
                    self.objectWillChange.send()
                }
            }.resume()
        }
    }

    @StateObject private var loader: Loader
    var loading: Image
    var failure: Image

    var body: some View {
        selectImage()
            .resizable()
    }

    init(url: String, loading: Image = Image(systemName: "photo"), failure: Image = Image(systemName: "multiply.circle")) {
        _loader = StateObject(wrappedValue: Loader(url: url))
        self.loading = loading
        self.failure = failure
    }

    private func selectImage() -> Image {
        switch loader.state {
        case .loading:
            return loading
        case .failure:
            return failure
        default:
            if let image = UIImage(data: loader.data) {
                return Image(uiImage: image)
            } else {
                return failure
            }
        }
    }
}

