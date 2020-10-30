import Foundation
import ReduxVM
import DITranquillity
import RedSwift
import DeclarativeTVC

fileprivate let dbQueue = DispatchQueue(label: "DBQueue", qos: .userInitiated)

protocol DBSideEffect: SideEffect {
}

extension DBSideEffect {
    var queue: DispatchQueue? { dbQueue }
}


class ToDBInteractor: Interactor<AppState>
{
    fileprivate let db: DBService

    init(store: Store<AppState>, db: DBService)
    {
        self.db = db
        super.init(store: store)
    }

    override public var sideEffects: [AnySideEffect]
    {
        [
            AddSourceSE(),
            RemoveSourceSE(),
            SetSourceActivitySE(),
            SetNewsSE(),
            SetUnreadSE(),
            SetUpdateIntervalSE(),
            SetStarredSE(),
        ]
    }
}

extension ToDBInteractor
{
    struct AddSourceSE: DBSideEffect
    {
        func condition(box: StateBox<AppState>) -> Bool
        {
            if let lastAction = box.lastAction as? SettingsState.AddSourcesAction, !lastAction.fromDB {
                return true
            }
            return false
        }

        func execute(box: StateBox<AppState>, trunk: Trunk, interactor: ToDBInteractor)
        {
            if let lastAction = box.lastAction as? SettingsState.AddSourcesAction {

                for url in lastAction.sources.map({ $0.url }) {
                    if let error = interactor.db.addSource(url: url, active: true) {
                        trunk.dispatch(AppState.ErrorAction(error: StateError.error(error.localizedDescription)))
                    }
                }
            }
        }
    }

    struct RemoveSourceSE: DBSideEffect
    {
        func condition(box: StateBox<AppState>) -> Bool
        {
            box.lastAction is SettingsState.RemoveSourceAction
        }

        func execute(box: StateBox<AppState>, trunk: Trunk, interactor: ToDBInteractor)
        {
            if let lastAction = box.lastAction as? SettingsState.RemoveSourceAction {

                if let error = interactor.db.removeSource(url: lastAction.sourceURL) {
                    trunk.dispatch(AppState.ErrorAction(error: StateError.error(error.localizedDescription)))
                }
                else {
                    trunk.dispatch(FinishAction())
                }
            }
        }

        struct FinishAction: Action { }
    }

    struct SetSourceActivitySE: DBSideEffect
    {
        func condition(box: StateBox<AppState>) -> Bool
        {
            box.lastAction is SettingsState.SetSourceActivityAction
        }

        func execute(box: StateBox<AppState>, trunk: Trunk, interactor: ToDBInteractor)
        {
            if let lastAction = box.lastAction as? SettingsState.SetSourceActivityAction {

                if let error = interactor.db.set(active: lastAction.activity, forSource: lastAction.sourceURL) {
                    trunk.dispatch(AppState.ErrorAction(error: StateError.error(error.localizedDescription)))
                }
                else {
                    trunk.dispatch(FinishAction())
                }
            }
        }

        struct FinishAction: Action { }
    }

    struct SetUnreadSE: DBSideEffect
    {
        func condition(box: StateBox<AppState>) -> Bool
        {
            box.lastAction is NewsState.SelectNewsAction
        }

        func execute(box: StateBox<AppState>, trunk: Trunk, interactor: ToDBInteractor)
        {
            if let lastAction = box.lastAction as? NewsState.SelectNewsAction {

                if let error = interactor.db.setRead(guid: lastAction.news.guid) {
                    trunk.dispatch(AppState.ErrorAction(error: StateError.error(error.localizedDescription)))
                }
            }
        }
    }

    struct SetStarredSE: DBSideEffect
    {
        func condition(box: StateBox<AppState>) -> Bool
        {
            box.lastAction is NewsState.SetStarAction
        }

        func execute(box: StateBox<AppState>, trunk: Trunk, interactor: ToDBInteractor)
        {
            if let lastAction = box.lastAction as? NewsState.SetStarAction {

                if let error = interactor.db.setStarred(guid: lastAction.news.guid, starred: lastAction.starred) {
                    trunk.dispatch(AppState.ErrorAction(error: StateError.error(error.localizedDescription)))
                }
                else {
                    trunk.dispatch(FinishAction())
                }
            }
        }

        struct FinishAction: Action { }
    }

    struct SetNewsSE: DBSideEffect
    {
        struct StartAction: Action {

            let sourceURL: String
            let news: [NewsState.Article]
        }

        func condition(box: StateBox<AppState>) -> Bool
        {
            box.lastAction is StartAction
        }

        func execute(box: StateBox<AppState>, trunk: Trunk, interactor: ToDBInteractor)
        {
            if let lastAction = box.lastAction as? StartAction {

                guard lastAction.news.count > 0 else {
                    return
                }
                interactor.db.set(news: lastAction.news, forSource: lastAction.sourceURL) { result in
                    switch result
                    {
                    case .success:
                        if box.state.settings.sources[lastAction.sourceURL] == true {
                            trunk.dispatch(FinishAction())
                        }
                    case .failure(let error):
                        trunk.dispatch(AppState.ErrorAction(error: StateError.error(error.localizedDescription)))
                    }
                }
            }
        }

        struct FinishAction: Action { }
    }

    struct SetUpdateIntervalSE: DBSideEffect
    {
        func condition(box: StateBox<AppState>) -> Bool
        {
            box.lastAction is SettingsState.SetUpdateIntervalAction && !(box.lastAction as! SettingsState.SetUpdateIntervalAction).fromDB
        }

        func execute(box: StateBox<AppState>, trunk: Trunk, interactor: ToDBInteractor)
        {
            if let lastAction = box.lastAction as? SettingsState.SetUpdateIntervalAction {

                if let error = interactor.db.set(updateInterval: lastAction.seconds) {
                    trunk.dispatch(AppState.ErrorAction(error: StateError.error(error.localizedDescription)))
                }
            }
        }
    }
}


