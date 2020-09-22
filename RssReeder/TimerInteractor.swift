//
//  TimerInteractor.swift
//  SwiftTrading
//
//  Created by Dmitry Kocherovets on 19.05.2020.
//  Copyright © 2020 Dmitry Kocherovets. All rights reserved.
//

import Foundation
import RedSwift
import ReduxVM

fileprivate var timer: DispatchSourceTimer?
fileprivate let queue = DispatchQueue(label: "com.TimerInteractor", attributes: .concurrent)

class TimerInteractor: Interactor<State> {

    override var sideEffects: [AnySideEffect] {
        [
            StartSE(),
            FinishSE()
        ]
    }

    deinit {

        timer?.cancel()
        timer = nil
    }
}

extension TimerInteractor {

    struct StartSE: SideEffect {

        struct StartAction: Action {

            func updateState(_ state: inout State) {
            }
        }

        func condition(box: StateBox<State>) -> Bool {

            box.lastAction is StartAction ||
                (box.lastAction is State.AddSourcesAction && !(box.lastAction as! State.AddSourcesAction).fromDB) ||
                box.lastAction is State.SetSourceActivityAction ||
                box.lastAction is State.SetUpdateIntervalAction
        }

        func execute(box: StateBox<State>, trunk: Trunk, interactor: TimerInteractor) {

            timer?.cancel()
            timer = DispatchSource.makeTimerSource(queue: queue)
            timer?.schedule(deadline: .now(), repeating: .seconds(box.state.updateIntervalSeconds), leeway: .milliseconds(100))
            timer?.setEventHandler {
                trunk.dispatch(UpdateNewsInteractor.UpdateNewsSE.StartAction())
            }
            timer?.resume()
        }
    }

    struct FinishSE: SideEffect {

        struct FinishAction: Action {

            func updateState(_ state: inout State) {
            }
        }

        func condition(box: StateBox<State>) -> Bool {

            box.lastAction is FinishAction
        }

        func execute(box: StateBox<State>, trunk: Trunk, interactor: TimerInteractor) {

            timer?.cancel()
            timer = nil
        }
    }
}
