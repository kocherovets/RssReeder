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
        ]
    }
}

extension SyncToDBInteractor
{
    struct AddSourceSE: SideEffect
    {
        func condition(box: StateBox<AppState>) -> Bool
        {
            if let lastAction = box.lastAction as? AppState.AddSourcesAction, !lastAction.fromDB {
                return true
            }
            return false
        }

        func execute(box: StateBox<AppState>, trunk: Trunk, interactor: SyncToDBInteractor)
        {
            if let lastAction = box.lastAction as? AppState.AddSourcesAction {

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
            box.lastAction is AppState.RemoveSourceAction
        }

        func execute(box: StateBox<AppState>, trunk: Trunk, interactor: SyncToDBInteractor)
        {
            if let lastAction = box.lastAction as? AppState.RemoveSourceAction {

                _ = interactor.db.removeSource(url: lastAction.sourceURL)
            }
        }
    }

    struct SetSourceActivitySE: SideEffect
    {
        func condition(box: StateBox<AppState>) -> Bool
        {
            box.lastAction is AppState.SetSourceActivityAction
        }

        func execute(box: StateBox<AppState>, trunk: Trunk, interactor: SyncToDBInteractor)
        {
            if let lastAction = box.lastAction as? AppState.SetSourceActivityAction {

                _ = interactor.db.set(active: lastAction.activity, forSource: lastAction.sourceURL)
            }
        }
    }

    struct SetUnreadSE: SideEffect
    {
        func condition(box: StateBox<AppState>) -> Bool
        {
            box.lastAction is RouterInteractor.ShowsNewsItemSE.ShowsAction
        }

        func execute(box: StateBox<AppState>, trunk: Trunk, interactor: SyncToDBInteractor)
        {
            if let lastAction = box.lastAction as? RouterInteractor.ShowsNewsItemSE.ShowsAction {

                _ = interactor.db.setRead(guid: lastAction.news.guid)
            }
        }
    }

    struct SetNewsSE: SideEffect
    {
        struct StartAction: Action {

            let sourceURL: String
            let news: [State.News]

            func updateState(_ state: inout AppState) {
            }
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
                let newItems = lastAction.news.sorted(by: { $0.time > $1.time })
                if
                    let lastDate = box.state.sources[lastAction.sourceURL]?.items.first?.time,
                    let newLastDate = newItems.first?.time,
                    lastDate >= newLastDate {
                    
                    return
                }
                
                _ = interactor.db.set(news: lastAction.news, forSource: lastAction.sourceURL)
            }
        }
    }
    
    struct SetUpdateIntervalSE: SideEffect
    {
        func condition(box: StateBox<AppState>) -> Bool
        {
            box.lastAction is AppState.SetUpdateIntervalAction && !(box.lastAction as! AppState.SetUpdateIntervalAction).fromDB
        }

        func execute(box: StateBox<AppState>, trunk: Trunk, interactor: SyncToDBInteractor)
        {
            if let lastAction = box.lastAction as? AppState.SetUpdateIntervalAction {

                _ = interactor.db.set(updateInterval: lastAction.seconds)
            }
        }
    }
}


