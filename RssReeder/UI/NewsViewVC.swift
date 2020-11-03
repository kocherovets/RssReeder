import Foundation
import ReduxVM
import DITranquillity
import RedSwift
import DeclarativeTVC

enum NewsViewVCModule {

    struct Props: Properties, Equatable {
        let rightBarButtonImageName: String
        let starCommand: Command
    }

    class Presenter: PresenterBase<AppState, Props, ViewController> {

        var uuid: UUID?

        override func reaction(for box: StateBox<AppState>) -> ReactionToState
        {
            box.lastAction is UIArticle ? .props : .none
        }

        override func props(for box: StateBox<AppState>, trunk: Trunk) -> Props? {

            if uuid == nil, case .showsArticle(let uuid) = box.state.lastRouting {
                self.uuid = uuid
            }
            guard
                let uuid = uuid,
                let selectedArticle = box.state.news[uuid]?.selectedArticle else
            {
                return nil
            }

            return Props(
                rightBarButtonImageName: selectedArticle.starred ? "star.fill" : "star",
                starCommand: Command {
                    trunk.dispatch(NewsState.SetStarAction(article: selectedArticle, starred: !selectedArticle.starred))
                }
            )
        }
    }
}

class NewsViewVC: VC, PropsReceiver {

    typealias Props = NewsViewVCModule.Props

    override func render() {

        guard let props = props else { return }

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: props.rightBarButtonImageName),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(starAction))
        navigationItem.rightBarButtonItem?.tintColor = UIColor(red: 1, green: 204.0/255.0, blue: 0, alpha: 1)
    }

    @objc func starAction() {
        props?.starCommand.perform()
    }
}

extension NewsViewVCModule
{
    typealias ViewController = NewsViewVC

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
