//
//  RssSwiftUIApp.swift
//  RssSwiftUI
//
//  Created by Dmitry Kocherovets on 06.11.2020.
//

import SwiftUI
import RedSwift
import DITranquillity
import RssState
import ReduxVM

public class AppFramework: DIFramework {
    public static func load(container: DIContainer) {

        container.append(part: RssStateModule.DI.self)
    }
}

let container = DIContainer()

var store: Store<AppState>!

class AppDelegate: UIResponder, UIApplicationDelegate
{
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool
    {
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

        store = container.resolve() as Store<AppState>
        
        InteractorLogger.loggingExcludedSideEffects = [
        ]

        RssStateModule.onAppStart(appContainer: container)
        
        return true
    }
}

@main
struct RssSwiftUIApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
