//
//  AppDelegate.swift
//  RssReeder
//
//  Created by Dmitry Kocherovets on 21.09.2020.
//

import UIKit
import CoreData
import DITranquillity
import RedSwift
import ReduxVM

class AppFramework: DIFramework
{
    static func load(container: DIContainer)
    {
        container.register(AppState.init).lifetime(.single)

        container.register { DispatchQueue(label: "rssReeder", qos: .userInteractive) }
            .as(DispatchQueue.self, name: "storeQueue")
            .lifetime(.single)

        container.register {
            Store<AppState>(state: $0,
                         queue: $1,
                         middleware: [
                             LoggingMiddleware(loggingExcludedActions: [
                                               ],
                                               firstPart: "RssReeder")
                         ])
        }
            .lifetime(.single) 

        container.register(DBService.init).lifetime(.single)

        container.register(RouterInteractor.init).lifetime(.single)
        container.register(TimerInteractor.init).lifetime(.single)
        container.register(UpdateNewsInteractor.init).lifetime(.single)
        container.register(SyncToDBInteractor.init).lifetime(.single)
        container.register(SyncFromDBInteractor.init).lifetime(.single)

        container.registerStoryboard(name: "Main", bundle: Bundle(for: NewsVC.self)).lifetime(.single)

        container.append(part: NewsVCModule.DI.self)
        container.append(part: NewsTVCModule.DI.self)
        container.append(part: NewsViewTVCModule.DI.self)
        container.append(part: SettingsTVCModule.DI.self)
    }
}

let container = DIContainer()

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        ReduxVMSettings.logRenderMessages = false
        ReduxVMSettings.logSkipRenderMessages = false
        ReduxVMSettings.logSubscribeMessages = false

        container.append(framework: AppFramework.self)

        #if DEBUG
        if !container.makeGraph().checkIsValid(checkGraphCycles: true) {
            fatalError("invalid graph")
        }
        #endif

        container.initializeSingletonObjects()

        InteractorLogger.loggingExcludedSideEffects = [
        ]
        
        (container.resolve() as Store<AppState>).dispatch(SyncFromDBInteractor.StartSyncSE.StartAction())

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

