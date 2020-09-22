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
        let rightBarButtonImageName: String
        let changeViewModeCommand: Command
    }

    class Presenter: PresenterBase<State, Props, ViewController> {

        override func reaction(for box: StateBox<State>) -> ReactionToState {
            return .props
        }

        override func props(for box: StateBox<State>, trunk: Trunk) -> Props? {

            Props(
                rightBarButtonImageName: box.state.hideBody ? "eye.slash" : "eye",
                changeViewModeCommand: Command {
                    trunk.dispatch(State.SetHideBodyAction(value: !box.state.hideBody))
                }
            )
        }
    }
}

class NewsVC: VC, PropsReceiver {

    typealias Props = NewsVCModule.Props

    override func render() {

        guard let props = props else { return }

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: props.rightBarButtonImageName),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(changeMode))
    }

    @IBAction func changeMode() {
        props?.changeViewModeCommand.perform()
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
