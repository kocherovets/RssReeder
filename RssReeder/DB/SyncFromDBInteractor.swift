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

protocol AnyDBSync
{
    func execute(trunk: Trunk, interactor: Any, objects: Set<NSManagedObject>)
}

protocol DBSync: AnyDBSync
{
    associatedtype Interactor

    func execute(trunk: Trunk, interactor: Interactor, objects: Set<NSManagedObject>)
}

extension DBSync
{
    func execute(trunk: Trunk, interactor: Any, objects: Set<NSManagedObject>)
    {
        execute(trunk: trunk, interactor: interactor as! Interactor, objects: objects)
    }
}

class SyncFromDBInteractor: Interactor<AppState>
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
            SyncNewsSE(),
        ]
    }

    var dbInsertSyncs: [AnyDBSync]
    {
        [
            NewsSync(),
        ]
    }

    var dbUpdateSyncs: [AnyDBSync]
    {
        []
    }

    var dbDeleteSyncs: [AnyDBSync]
    {
        []
    }

    var dbRefreshSyncs: [AnyDBSync]
    {
        []
    }

    @objc func contextSave(_ notification: Notification)
    {
        print("---contextSave---")
        if
            let insertedObjects = notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject>,
            !insertedObjects.isEmpty
        {
            print(insertedObjects)
            for dbSync in dbInsertSyncs
            {
                dbSync.execute(trunk: self, interactor: self, objects: insertedObjects)
            }
        }
        if
            let updatedObjects = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject>,
            !updatedObjects.isEmpty
        {
            print(updatedObjects)
            for dbSync in dbUpdateSyncs
            {
                dbSync.execute(trunk: self, interactor: self, objects: updatedObjects)
            }
        }
        if
            let deletedObjects = notification.userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject>,
            !deletedObjects.isEmpty
        {
            print(deletedObjects)
            for dbSync in dbDeleteSyncs
            {
                dbSync.execute(trunk: self, interactor: self, objects: deletedObjects)
            }
        }
        if
            let refreshedObjects = notification.userInfo?[NSRefreshedObjectsKey] as? Set<NSManagedObject>,
            !refreshedObjects.isEmpty
        {
            print(refreshedObjects)
            for dbSync in dbRefreshSyncs
            {
                dbSync.execute(trunk: self, interactor: self, objects: refreshedObjects)
            }
        }
        if
            let invalidatedObjects = notification.userInfo?[NSInvalidatedObjectsKey] as? Set<NSManagedObject>,
            !invalidatedObjects.isEmpty
        {
            print(invalidatedObjects)
        }
        if
            let areInvalidatedAllObjects = notification.userInfo?[NSInvalidatedAllObjectsKey] as? Bool
        {
            print(areInvalidatedAllObjects)
        }
    }
}

extension Action {

    func updateState(_ state: inout AppState) { }
}

extension SyncFromDBInteractor
{
    struct StartSyncSE: SideEffect
    {
        struct StartAction: Action { }

        func condition(box: StateBox<AppState>) -> Bool
        {
            box.lastAction is StartAction
        }

        func execute(box: StateBox<AppState>, trunk: Trunk, interactor: SyncFromDBInteractor)
        {
            NotificationCenter.default.addObserver(interactor,
                                                   selector: #selector(interactor.contextSave(_:)),
                                                   name: NSNotification.Name.NSManagedObjectContextDidSave,
                                                   object: nil)

            switch interactor.db.sources() {
            case .success(let sources):
                let infos = sources
                    .map { AppState.AddSourcesAction.Info(url: $0.url, active: $0.active) }
                trunk.dispatch(AppState.AddSourcesAction(sources: infos,
                                                      fromDB: true))

                for info in infos.filter({ $0.active }) {

                    interactor.getNews(trunk: trunk, interactor: interactor, sourceURL: info.url)
                }

                switch interactor.db.updateInterval() {
                case .success(let updateInterval):
                    trunk.dispatch(AppState.SetUpdateIntervalAction(seconds: updateInterval,
                                                                 fromDB: true))
                case .failure(let error):
                    trunk.dispatch(AppState.ErrorAction(error: StateError.error(error.localizedDescription)))
                }

            case .failure(let error):
                trunk.dispatch(AppState.ErrorAction(error: StateError.error(error.localizedDescription)))
            }
        }
    }

    struct SyncNewsSE: SideEffect
    {
        func condition(box: StateBox<AppState>) -> Bool
        {
            box.lastAction is AppState.SetSourceActivityAction
        }

        func execute(box: StateBox<AppState>, trunk: Trunk, interactor: SyncFromDBInteractor)
        {
            if let lastAction = box.lastAction as? AppState.SetSourceActivityAction, lastAction.activity {

                interactor.getNews(trunk: trunk, interactor: interactor, sourceURL: lastAction.sourceURL)
            }
        }
    }
}

extension SyncFromDBInteractor
{
    fileprivate func getNews(trunk: Trunk, interactor: SyncFromDBInteractor, sourceURL: String) {

        switch interactor.db.news(forSource: sourceURL) {
        case .success(let dbNews):
            let news = dbNews
                .map {
                    AppState.News(sourceURL: sourceURL,
                           source: $0.sourceTitle,
                           guid: $0.guid,
                           title: $0.title,
                           body: $0.body,
                           time: $0.time,
                           imageURL: $0.imageURL,
                           unread: $0.unread)
            }
            trunk.dispatch(AppState.AppendNewsAction(sourceURL: sourceURL, news: news))
        case .failure(let error):
            trunk.dispatch(AppState.ErrorAction(error: StateError.error(error.localizedDescription)))
        }
    }

    struct NewsSync: DBSync
    {
        func execute(trunk: Trunk, interactor: SyncFromDBInteractor, objects: Set<NSManagedObject>)
        {
            if let object = objects.first as? DBNews {

                interactor.getNews(trunk: trunk, interactor: interactor, sourceURL: object.source.url)
            }
        }
    }
}
