import Foundation
import RedSwift
import ReduxVM

fileprivate var timer: DispatchSourceTimer?
fileprivate let queue = DispatchQueue(label: "com.TimerInteractor", attributes: .concurrent)

class TimerInteractor: Interactor<AppState> {

    override var sideEffects: [AnySideEffect] {
        [
            StartTimerSE(),
            FinishTimerSE()
        ]
    }

    deinit {

        timer?.cancel()
        timer = nil
    }
}

extension TimerInteractor {

    struct StartTimerSE: SideEffect {

        func condition(box: StateBox<AppState>) -> Bool {

            box.lastAction is ToDBInteractor.AddSourceSE.FinishAction ||
                box.lastAction is SettingsState.SetUpdateIntervalAction
        }

        func execute(box: StateBox<AppState>, trunk: Trunk, interactor: TimerInteractor) {

            timer?.cancel()
            timer = DispatchSource.makeTimerSource(queue: queue)
            timer?.schedule(deadline: .now(),
                            repeating: .seconds(box.state.settings.updateIntervalSeconds),
                            leeway: .milliseconds(100))
            timer?.setEventHandler {
                trunk.dispatch(FinishAction())
            }
            timer?.resume()
        }
        
        struct FinishAction: Action { }
    }

    struct FinishTimerSE: SideEffect {

        struct StartAction: Action { }

        func condition(box: StateBox<AppState>) -> Bool {

            box.lastAction is StartAction
        }

        func execute(box: StateBox<AppState>, trunk: Trunk, interactor: TimerInteractor) {

            timer?.cancel()
            timer = nil
        }
    }
}
