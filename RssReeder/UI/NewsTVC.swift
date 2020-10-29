import Foundation
import ReduxVM
import DITranquillity
import RedSwift
import DeclarativeTVC

enum NewsTVCModule
{
    class Presenter: PresenterBase<AppState, TableProps, ViewController>
    {
        var uuid: UUID?

        override func reaction(for box: StateBox<AppState>) -> ReactionToState
        {
            box.lastAction is UINews ? .props : .none
        }

        override func props(for box: StateBox<AppState>, trunk: Trunk) -> TableProps?
        {
            guard
                let uuid = uuid,
                let newsState = box.state.news[uuid] else
            {
                return nil
            }

            var sections = [TableSection]()

            for date in newsState.news.keys.sorted().reversed() {

                guard let items = newsState.news[date] else { continue }
                
                sections.append(
                    TableSection(header: NewsHeaderCellVM(title: headerDateFormatter.string(from: date)),
                                 rows: items.map { news in
                                     NewsCellVM(source: news.source.uppercased(),
                                                title: news.title,
                                                body: news.body,
                                                hideBody: newsState.hideBody,
                                                time: dateFormatter.string(from: news.time),
                                                imageURL: news.imageURL,
                                                unread: news.unread,
                                                starred: news.starred,
                                                selectCommand: Command {
                                                    trunk.dispatch(NewsState.SelectNewsAction(uuid: uuid, news: news))
                                                })
                                 },
                                 footer: nil)
                )
            }

            return TableProps(tableModel: TableModel(sections: sections))
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
    }
}

class NewsTVC: TVC, PropsReceiver
{
    typealias Props = TableProps
}

extension NewsTVCModule
{
    typealias ViewController = NewsTVC

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
