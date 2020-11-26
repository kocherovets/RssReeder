import Foundation
import RedSwift
import CoreData

public class FromDBInteractor: Interactor<AppState>
{
    fileprivate let db: DBService

    public init(store: Store<AppState>, db: DBService)
    {
        self.db = db

        super.init(store: store)
    }

    public override var sideEffects: [AnySideEffect]
    {
        [
            StartSyncSE(),
            UpdateIntervalSE(),
            LoadNewsSE(),
        ]
    }
}

public struct StartAppAction: Action {
    public init() {}
    public func updateState(_ state: inout State) {}
}

extension FromDBInteractor
{
    struct StartSyncSE: DBSideEffect
    {
        func condition(box: StateBox<AppState>) -> Bool
        {
            box.lastAction is StartAppAction
        }

        func execute(box: StateBox<AppState>, trunk: Trunk, interactor: FromDBInteractor)
        {
            interactor.db.sources() { result in
                switch result
                {
                case .success(let sources):
                    trunk.dispatch(
                        SettingsState.AddSourcesAction(
                            sources: sources.map {
                                SettingsState.AddSourcesAction.Info(url: $0.url,
                                                                    active: $0.active)
                            },
                            fromDB: true)
                    )
                case .failure(let error):
                    trunk.dispatch(AppState.ErrorAction(error: StateError.error(error.localizedDescription)))
                }
            }
        }
    }

    struct UpdateIntervalSE: DBSideEffect
    {
        func condition(box: StateBox<AppState>) -> Bool
        {
            (box.lastAction as? SettingsState.AddSourcesAction)?.fromDB == true
        }

        func execute(box: StateBox<AppState>, trunk: Trunk, interactor: FromDBInteractor)
        {
            interactor.db.updateInterval() { result in
                switch result {
                case .success(let updateInterval):
                    trunk.dispatch(
                        SettingsState.SetUpdateIntervalAction(seconds: updateInterval,
                                                              fromDB: true)
                    )
                case .failure(let error):
                    trunk.dispatch(AppState.ErrorAction(error: StateError.error(error.localizedDescription)))
                }
            }
        }
    }

    struct LoadNewsSE: DBSideEffect
    {
        func condition(box: StateBox<AppState>) -> Bool
        {
            box.lastAction is NewsState.AddNewsStateAction ||
                box.lastAction is ToDBInteractor.RemoveSourceSE.FinishAction ||
                box.lastAction is ToDBInteractor.SetSourceActivitySE.FinishAction ||
                box.lastAction is ToDBInteractor.SetNewsSE.FinishAction ||
                box.lastAction is NewsState.ShowsOnlyStarredAction ||
                box.lastAction is ToDBInteractor.SetStarredSE.FinishAction
        }

        func execute(box: StateBox<AppState>, trunk: Trunk, interactor: FromDBInteractor)
        {
            for (uuid, newsState) in box.state.news {
                interactor.db.news(onlyStarred: newsState.showsStarredOnly) { result in
                    switch result {
                    case .success(let days):
                        trunk.dispatch(NewsState.SetNewsAction(newsUUID: uuid, days: days))
                    case .failure(let error):
                        trunk.dispatch(AppState.ErrorAction(error: StateError.error(error.localizedDescription)))
                    }
                }
            }
        }
    }
}
