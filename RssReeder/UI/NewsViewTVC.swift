import Foundation
import ReduxVM
import DITranquillity
import RedSwift
import DeclarativeTVC

enum NewsViewTVCModule
{
    class Presenter: PresenterBase<AppState, TableProps, ViewController>
    {
        var uuid: UUID?
        
        override func reaction(for box: StateBox<AppState>) -> ReactionToState
        {
            box.lastAction is UIArticle ? .props : .none
        }

        override func props(for box: StateBox<AppState>, trunk: Trunk) -> TableProps?
        {
            if uuid == nil, case .showsArticle(let uuid) = box.state.lastRouting {
                self.uuid = uuid
            }
            guard let uuid = uuid else { return nil }
            
            var rows = [CellAnyModel]()

            if let news = box.state.news[uuid]?.selectedArticle {
                
                rows.append(NewsDateCellVM(date: dateFormatter.string(from: news.time).uppercased()))
                rows.append(NewsTitleCellVM(title: news.title))
                rows.append(NewsSourceCellVM(source: news.source.uppercased()))
                rows.append(NewsBodyCellVM(body: news.body))
                rows.append(NewsImageCellVM(imageURL: news.imageURL))
            }

            return TableProps(tableModel: TableModel(rows: rows))
        }

        var dateFormatter: DateFormatter = {

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE, dd MMMM yyyy, HH:mm"
            return dateFormatter
        }()
    }
}

class NewsViewTVC: TVC, PropsReceiver
{
    typealias Props = TableProps
}

extension NewsViewTVCModule
{
    typealias ViewController = NewsViewTVC

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
