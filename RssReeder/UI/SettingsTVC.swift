import Foundation
import ReduxVM
import DITranquillity
import RedSwift
import DeclarativeTVC
import RssState

enum SettingsTVCModule
{
    class Presenter: PresenterBase<AppState, TableProps, ViewController>
    {
        private var localDate = Date.distantPast

        override func reaction(for box: StateBox<AppState>) -> ReactionToState
        {
            box.lastAction is UISettings ? .props : .none
        }

        override func props(for box: StateBox<AppState>, trunk: Trunk) -> TableProps?
        {
            let generalSection = TableSection(
                header: TitleWithoutViewTableHeaderModel(title: "General"),
                rows: [
                    UpdateIntervalCellVM(
                        text: String(box.state.settings.updateIntervalSeconds),
                        valueChangedCommand: CommandWith<Int> { value in
                            trunk.dispatch(SettingsState.SetUpdateIntervalAction(seconds: value,
                                                                                 fromDB: false))
                        }
                    )
                ],
                footer: nil)

            var rows = [CellAnyModel]()
            rows.append(contentsOf:
                box.state.settings.sources.keys.sorted()
                .map { url in
                    let isActive = box.state.settings.sources[url] == true
                    return SourceCellVM(title: url,
                                        isActive: isActive,
                                        valueChangedCommand: Command {
                                            trunk.dispatch(SettingsState.SetSourceActivityAction(sourceURL: url,
                                                                                                 activity: !isActive))
                                        },
                                        removeCommand: Command {
                                            trunk.dispatch(SettingsState.RemoveSourceAction(sourceURL: url))
                                        })
            })

            rows.append(
                AddSourceCellVM(
                    title: "Add source from clipoard",
                    selectCommand: Command {
                        if let url = UIPasteboard.general.string?.trimmingCharacters(in: .whitespaces) {
                            trunk.dispatch(SettingsState.AddSourcesAction(
                                sources: [SettingsState.AddSourcesAction.Info(url: url,
                                                                              active: true)],
                                fromDB: false))
                        }
                    }))

            struct RssFeed {
                let url: String
                let title: String
            }
            [
                RssFeed(url: "https://www.nasa.gov/rss/dyn/breaking_news.rss", title: "Add NASA breaking news"),
                RssFeed(url: "https://www.nasa.gov/rss/dyn/educationnews.rss", title: "Add NASA education news"),
                RssFeed(url: "https://www.smithsonianmag.com/rss/photos/", title: "Add photos feed"),
                RssFeed(url: "https://www.washingtontimes.com/rss/headlines/news/local/", title: "Washington Times: Local"),
                RssFeed(url: "https://www.washingtontimes.com/rss/headlines/news/politics/", title: "Washington Times: Politics"),
            ]
                .forEach
            { feed in
                if box.state.settings.sources.keys.first(where: { $0 == feed.url }) == nil {
                    rows.append(
                        AddSourceCellVM(
                            title: feed.title,
                            selectCommand: Command {
                                trunk.dispatch(SettingsState.AddSourcesAction(
                                    sources: [SettingsState.AddSourcesAction.Info(url: feed.url,
                                                                                  active: true)],
                                    fromDB: false))
                            })
                    )
                }
            }

            let sourcesSection = TableSection(
                header: TitleWithoutViewTableHeaderModel(title: "Sources"),
                rows: rows,
                footer: nil)
                                                                        
            return TableProps(tableModel: TableModel(sections: [generalSection, sourcesSection]),
                              animations: DeclarativeTVC.fadeAnimations)
        }
    }
}

class SettingsTVC: TVC, PropsReceiver
{
    typealias Props = TableProps

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {

        props?.tableModel.sections[indexPath.section].rows[indexPath.row] is SourceCellVM
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {

            if let vm = props?.tableModel.sections[indexPath.section].rows[indexPath.row] as? SourceCellVM {
                vm.removeCommand.perform()
            }
        }
    }
}

extension SettingsTVCModule
{
    typealias ViewController = SettingsTVC

    class DI: DIPart
    {
        static func load(container: DIContainer)
        {
            container.register(ViewController.self)
                .injection(\ViewController.presenter) {
                    $0 as Presenter
                }
                .lifetime(.objectGraph)

            container.register(Presenter.init)
                .injection(cycle: true, \Presenter.propsReceiver)
                .lifetime(.objectGraph)
        }
    }
}

