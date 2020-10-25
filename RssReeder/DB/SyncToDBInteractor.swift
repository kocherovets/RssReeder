//
//  SyncToDBInteractor.swift
//  RecordingLogic
//
//  Created by Dmitry Kocherovets on 23.01.2020.
//  Copyright © 2020 Gaika Group. All rights reserved.
//

import Foundation
import ReduxVM
import DITranquillity
import RedSwift
import DeclarativeTVC

class SyncToDBInteractor: Interactor<AppState>
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

extension SyncToDBInteractor
{
    struct AddSourceSE: SideEffect
    {
        func condition(box: StateBox<AppState>) -> Bool
        {
            if let lastAction = box.lastAction as? SettingsState.AddSourcesAction, !lastAction.fromDB {
                return true
            }
            return false
        }

        func execute(box: StateBox<AppState>, trunk: Trunk, interactor: SyncToDBInteractor)
        {
            if let lastAction = box.lastAction as? SettingsState.AddSourcesAction {

                for url in lastAction.sources.map({ $0.url }) {
                    _ = interactor.db.addSource(url: url, active: true)
                }
            }
        }
    }

    struct RemoveSourceSE: SideEffect
    {
        func condition(box: StateBox<AppState>) -> Bool
        {
            box.lastAction is SettingsState.RemoveSourceAction
        }

        func execute(box: StateBox<AppState>, trunk: Trunk, interactor: SyncToDBInteractor)
        {
            if let lastAction = box.lastAction as? SettingsState.RemoveSourceAction {

                _ = interactor.db.removeSource(url: lastAction.sourceURL)

                for uuid in box.state.news.keys {
                    trunk.dispatch(SyncFromDBInteractor.LoadNewsSE.StartAction(uuid: uuid))
                }
            }
        }
    }

    struct SetSourceActivitySE: SideEffect
    {
        func condition(box: StateBox<AppState>) -> Bool
        {
            box.lastAction is SettingsState.SetSourceActivityAction
        }

        func execute(box: StateBox<AppState>, trunk: Trunk, interactor: SyncToDBInteractor)
        {
            if let lastAction = box.lastAction as? SettingsState.SetSourceActivityAction {

                _ = interactor.db.set(active: lastAction.activity, forSource: lastAction.sourceURL)

                for uuid in box.state.news.keys {
                    trunk.dispatch(SyncFromDBInteractor.LoadNewsSE.StartAction(uuid: uuid))
                }
            }
        }
    }

    struct SetUnreadSE: SideEffect
    {
        func condition(box: StateBox<AppState>) -> Bool
        {
            box.lastAction is NewsState.SelectNewsAction
        }

        func execute(box: StateBox<AppState>, trunk: Trunk, interactor: SyncToDBInteractor)
        {
            if let lastAction = box.lastAction as? NewsState.SelectNewsAction {

                _ = interactor.db.setRead(guid: lastAction.news.guid)
            }
        }
    }

    struct SetStarredSE: SideEffect
    {
        func condition(box: StateBox<AppState>) -> Bool
        {
            box.lastAction is NewsState.SetStarAction
        }

        func execute(box: StateBox<AppState>, trunk: Trunk, interactor: SyncToDBInteractor)
        {
            if let lastAction = box.lastAction as? NewsState.SetStarAction {

                _ = interactor.db.setStarred(guid: lastAction.guid, starred: lastAction.starred) 
            }
        }
    }
    
    struct SetNewsSE: SideEffect
    {
        struct StartAction: Action {

            let sourceURL: String
            let news: [NewsState.News]
        }

        func condition(box: StateBox<AppState>) -> Bool
        {
            box.lastAction is StartAction
        }

        func execute(box: StateBox<AppState>, trunk: Trunk, interactor: SyncToDBInteractor)
        {
            if let lastAction = box.lastAction as? StartAction {

                guard lastAction.news.count > 0 else {
                    return
                }
                if let error = interactor.db.set(news: lastAction.news, forSource: lastAction.sourceURL) {

                    trunk.dispatch(AppState.ErrorAction(error: StateError.error(error.localizedDescription)))
                } else {
                    for uuid in box.state.news.keys {
                        trunk.dispatch(SyncFromDBInteractor.LoadNewsSE.StartAction(uuid: uuid))
                    }
                }
            }
        }
    }

    struct SetUpdateIntervalSE: SideEffect
    {
        func condition(box: StateBox<AppState>) -> Bool
        {
            box.lastAction is SettingsState.SetUpdateIntervalAction && !(box.lastAction as! SettingsState.SetUpdateIntervalAction).fromDB
        }

        func execute(box: StateBox<AppState>, trunk: Trunk, interactor: SyncToDBInteractor)
        {
            if let lastAction = box.lastAction as? SettingsState.SetUpdateIntervalAction {

                _ = interactor.db.set(updateInterval: lastAction.seconds)
            }
        }
    }
}


