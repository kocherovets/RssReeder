//
//  RssStateModule.swift
//  RssState
//
//  Created by Dmitry Kocherovets on 06.11.2020.
//

import Foundation
import DITranquillity
import RedSwift

var container: DIContainer!

public class RssStateModule
{
    public class DI: DIPart
    {
        public static func load(container: DIContainer)
        {
            container.register(AppState.init).lifetime(.single)

            container.register { DispatchQueue(label: "rssReeder", qos: .userInitiated) }
                .as(DispatchQueue.self, name: "storeQueue")
                .lifetime(.single)

            container.register {
                Store<AppState>(state: $0,
                                queue: $1,
                                middleware: [LoggingMiddleware(loggingExcludedActions: [],
                                                               firstPart: "RssReeder")
                                ])
            }
                .lifetime(.single)

            container.register(DBService.init).lifetime(.single)

            container.register(TimerInteractor.init).lifetime(.single)
            container.register(UpdateNewsInteractor.init).lifetime(.single)
            container.register(ToDBInteractor.init).lifetime(.single)
            container.register(FromDBInteractor.init).lifetime(.single)
        }
    }
    
    public class func onAppStart(appContainer: DIContainer)
    {
        container = appContainer
        
        (container.resolve() as Store<AppState>).dispatch(FromDBInteractor.StartSyncSE.StartAction())
    }
}
