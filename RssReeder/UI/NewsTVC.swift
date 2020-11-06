import Foundation
import ReduxVM
import DITranquillity
import RedSwift
import DeclarativeTVC
import RssState

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

            for day in newsState.days {

                guard day.articles.count > 0 else { continue }

                sections.append(
                    TableSection(header: NewsHeaderCellVM(title: headerDateFormatter.string(from: day.date)),
                                 rows: day.articles.map { article in
                                     NewsCellVM(source: article.source.uppercased(),
                                                title: article.title,
                                                body: article.body,
                                                hideBody: newsState.hideBody,
                                                time: dateFormatter.string(from: article.time),
                                                imageURL: article.imageURL,
                                                unread: article.unread,
                                                starred: article.starred,
                                                selectCommand: Command {
                                                    trunk.dispatch(NewsState.SelectNewsAction(newsUUID: uuid,
                                                                                              article: article))
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
