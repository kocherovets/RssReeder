//
//  Store.swift
//  latoken
//
//  Created by Dmitry Kocherovets on 09.05.2020.
//  Copyright © 2020 Dmitry Kocherovets. All rights reserved.
//

import Foundation
import RedSwift

struct AppState: RootStateType, Equatable
{
    struct News: Equatable {
        var sourceURL: String
        var source: String
        var guid: String
        var title: String
        var body: String
        var time: Date
        var imageURL: String
        var unread: Bool
    }
    var hideBody = false { didSet { lastUpdateTS = Date() } }
    var selectedNews: News?

    struct SourceInfo: Equatable {
        var items = [News]()
        var active = true
    }
    var sources: [String: SourceInfo] = [:] { didSet { lastUpdateTS = Date() } }
    var updateIntervalSeconds: Int = 10
    var lastUpdateTS = Date()

    var news: [News] {

        sources.values
            .filter({ $0.active })
            .map({ $0.items })
            .flatMap(({ (element: [News]) -> [News] in
                    return element
            }))
            .sorted(by: { $0.time > $1.time })
    }

    var error = StateError.none
}

enum StateError: Error, Equatable {
    case none
    case error(String)
}

extension AppState
{
    struct ErrorAction: Action
    {
        let error: StateError

        func updateState(_ state: inout AppState)
        {
            state.error = error
        }
    }

    struct SetHideBodyAction: Action
    {
        let value: Bool

        func updateState(_ state: inout AppState)
        {
            state.hideBody = value
        }
    }

    struct AppendNewsAction: Action
    {
        let sourceURL: String
        let news: [News]

        func updateState(_ state: inout AppState)
        {
            guard news.count > 0 else {
                return
            }
            state.sources[sourceURL]?.items = news.sorted(by: { $0.time > $1.time })
        }

        init(sourceURL: String, news: [News])
        {
            self.sourceURL = sourceURL
            self.news = news
        }
    }

    struct AddSourcesAction: Action
    {
        struct Info {
            let url: String
            let active: Bool
        }

        let sources: [Info]
        let fromDB: Bool

        func updateState(_ state: inout AppState)
        {
            for source in sources {
                state.sources[source.url] = SourceInfo(active: source.active)
            }
        }
    }

    struct RemoveSourceAction: Action
    {
        let sourceURL: String

        func updateState(_ state: inout AppState)
        {
            state.sources[sourceURL] = nil
        }
    }

    struct SetSourceActivityAction: Action
    {
        let sourceURL: String
        let activity: Bool

        func updateState(_ state: inout AppState)
        {
            state.sources[sourceURL]?.active = activity
        }
    }

    struct SetUpdateIntervalAction: Action
    {
        let seconds: Int
        let fromDB: Bool

        func updateState(_ state: inout AppState)
        {
            state.updateIntervalSeconds = max(10, seconds)
        }
    }
}
