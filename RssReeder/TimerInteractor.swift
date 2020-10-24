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

class TimerInteractor: Interactor<AppState> {

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

        func condition(box: StateBox<AppState>) -> Bool {

            box.lastAction is StartAction ||
                (box.lastAction is AppState.AddSourcesAction && !(box.lastAction as! AppState.AddSourcesAction).fromDB) ||
                box.lastAction is AppState.SetSourceActivityAction ||
                box.lastAction is AppState.SetUpdateIntervalAction
        }

        func execute(box: StateBox<AppState>, trunk: Trunk, interactor: TimerInteractor) {

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

        func condition(box: StateBox<AppState>) -> Bool {

            box.lastAction is FinishAction
        }

        func execute(box: StateBox<AppState>, trunk: Trunk, interactor: TimerInteractor) {

            timer?.cancel()
            timer = nil
        }
    }
}
