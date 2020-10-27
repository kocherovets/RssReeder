//
//  SyncFromDBInteractor.swift
//  RecordingLogic
//
//  Created by Dmitry Kocherovets on 13.04.2020.
//  Copyright © 2020 Gaika Group. All rights reserved.
//

import Foundation
import ReduxVM
import DITranquillity
import RedSwift
import DeclarativeTVC
import CoreData

class FromDBInteractor: Interactor<AppState>
{
    fileprivate let db: DBService

    init(store: Store<AppState>, db: DBService)
    {
        self.db = db

        super.init(store: store)
    }

    override var sideEffects: [AnySideEffect]
    {
        [
            StartSyncSE(),
            LoadNewsSE(),
            LoadNewsAfterStarredSE(),
        ]
    }
}

extension FromDBInteractor
{
    struct StartSyncSE: SideEffect
    {
        struct StartAction: Action { }

        func condition(box: StateBox<AppState>) -> Bool
        {
            box.lastAction is StartAction
        }

        func execute(box: StateBox<AppState>, trunk: Trunk, interactor: FromDBInteractor)
        {
            switch interactor.db.sources() {
            case .success(let sources):
                let infos = sources
                    .map { SettingsState.AddSourcesAction.Info(url: $0.url, active: $0.active) }
                trunk.dispatch(SettingsState.AddSourcesAction(sources: infos,
                                                              fromDB: true))

                for uuid in box.state.news.keys {
                    interactor.getNews(uuid: uuid,
                                       showsOnlyStarred: box.state.news[uuid]?.showsStarredOnly ?? false,
                                       trunk: trunk,
                                       interactor: interactor)
                }

                switch interactor.db.updateInterval() {
                case .success(let updateInterval):
                    trunk.dispatch(SettingsState.SetUpdateIntervalAction(seconds: updateInterval,
                                                                         fromDB: true))
                case .failure(let error):
                    trunk.dispatch(AppState.ErrorAction(error: StateError.error(error.localizedDescription)))
                }

            case .failure(let error):
                trunk.dispatch(AppState.ErrorAction(error: StateError.error(error.localizedDescription)))
            }
        }
    }

    struct LoadNewsSE: SideEffect
    {
        struct StartAction: Action {
            let from: Int
        }

        func condition(box: StateBox<AppState>) -> Bool
        {
            box.lastAction is StartAction ||
                box.lastAction is NewsState.AddNewsStateAction ||
                (box.lastAction is NewsState.ShowsOnlyStarredAction && (box.lastAction as! NewsState.ShowsOnlyStarredAction).value == false)
        }

        func execute(box: StateBox<AppState>, trunk: Trunk, interactor: FromDBInteractor)
        {
            for uuid in box.state.news.keys {
                interactor.getNews(uuid: uuid,
                                   showsOnlyStarred: false,
                                   trunk: trunk,
                                   interactor: interactor)
            }
        }
    }

    struct LoadNewsAfterStarredSE: SideEffect
    {
        func condition(box: StateBox<AppState>) -> Bool
        {
            if let lastAction = box.lastAction as? NewsState.ShowsOnlyStarredAction, lastAction.value {
                return true
            }
            if box.lastAction is ToDBInteractor.SetStarredSE.FinishAction {
                return true
            }
            return false
        }

        func execute(box: StateBox<AppState>, trunk: Trunk, interactor: FromDBInteractor)
        {
            for uuid in box.state.news.keys {
                if
                    box.state.news[uuid]?.showsStarredOnly != true
                {
                    continue
                }
                interactor.getNews(uuid: uuid,
                                   showsOnlyStarred: true,
                                   trunk: trunk,
                                   interactor: interactor)
            }
        }
    }

    func getNews(uuid: UUID, showsOnlyStarred: Bool, trunk: Trunk, interactor: FromDBInteractor) {

        switch interactor.db.news(onlyStarred: showsOnlyStarred) {
        case .success(let news):
            trunk.dispatch(NewsState.SetNewsAction(uuid: uuid, news: news))
        case .failure(let error):
            trunk.dispatch(AppState.ErrorAction(error: StateError.error(error.localizedDescription)))
        }
    }
}
