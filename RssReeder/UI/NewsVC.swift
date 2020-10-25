//
//  ViewController.swift
//  MoviesDB
//
//  Created by Dmitry Kocherovets on 10.11.2019.
//  Copyright © 2019 Dmitry Kocherovets. All rights reserved.
//

import Foundation
import ReduxVM
import DITranquillity
import RedSwift
import DeclarativeTVC

enum NewsVCModule {

    struct Props: Properties, Equatable {
        let leftBarButtonImageName: String
        let leftBarButtonTintColor: UIColor?
        let showsStarredOnlyCommand: Command
        let rightBarButtonImageName: String
        let changeViewModeCommand: Command
    }

    class Presenter: PresenterBase<AppState, Props, ViewController> {

        var uuid = UUID()

        override func reaction(for box: StateBox<AppState>) -> ReactionToState {
            return .props
        }

        override func props(for box: StateBox<AppState>, trunk: Trunk) -> Props? {

            guard let news = box.state.news[uuid] else {
                return nil
            }

            return Props(
                leftBarButtonImageName: news.showsStarredOnly ? "star.fill" : "star",
                leftBarButtonTintColor: news.showsStarredOnly ? UIColor(red: 1, green: 204.0/255.0, blue: 0, alpha: 1) : nil,
                showsStarredOnlyCommand: Command {
                    trunk.dispatch(NewsState.ShowsOnlyStarredAction(uuid: self.uuid, value: !news.showsStarredOnly))
                },
                rightBarButtonImageName: news.hideBody ? "eye.slash" : "eye",
                changeViewModeCommand: Command {
                    trunk.dispatch(NewsState.SetHideBodyAction(uuid: self.uuid, value: !news.hideBody))
                }
            )
        }
    }
}

class NewsVC: VC, PropsReceiver {

    typealias Props = NewsVCModule.Props

    override func render() {

        guard let props = props else { return }

        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: props.leftBarButtonImageName),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(showsStarredOnly))
        navigationItem.leftBarButtonItem?.tintColor = props.leftBarButtonTintColor

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: props.rightBarButtonImageName),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(changeMode))
    }

    @objc func showsStarredOnly() {
        props?.showsStarredOnlyCommand.perform()
    }

    @objc func changeMode() {
        props?.changeViewModeCommand.perform()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let vc = segue.destination as? NewsTVC {
            (vc.presenter as? NewsTVCModule.Presenter)?.uuid = (presenter as? NewsVCModule.Presenter)?.uuid
        }
    }
}

extension NewsVCModule
{
    typealias ViewController = NewsVC

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
