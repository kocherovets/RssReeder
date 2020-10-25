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
    var news = [UUID: NewsState]()
    var settings = SettingsState()
    var error = StateError.none

    struct ErrorAction: Action
    {
        let error: StateError

        func updateState(_ state: inout AppState)
        {
            state.error = error
        }
    }
}

enum StateError: Error, Equatable {
    case none
    case error(String)
}

struct NewsState: StateType, Equatable
{
    struct News: Equatable {
        var source: String
        var guid: String
        var title: String
        var body: String
        var time: Date
        var imageURL: String
        var unread: Bool
    }
    var hideBody = false
    var selectedNews: News?
    var news = [News]()

    struct AddNewsStateAction: Action, UIUpdateNews
    {
        let uuid: UUID

        func updateState(_ state: inout AppState)
        {
            state.news[uuid] = NewsState()
        }
    }

    struct SetHideBodyAction: Action, UIUpdateNews
    {
        let uuid: UUID
        let value: Bool

        func updateState(_ state: inout AppState)
        {
            state.news[uuid]?.hideBody = value
        }
    }

    struct SetNewsAction: Action, UIUpdateNews
    {
        let news: [News]

        func updateState(_ state: inout AppState)
        {
            for uuid in state.news.keys {
                state.news[uuid]?.news = news
            }
        }
    }

    struct SelectNewsAction: Action, UIUpdateNews {

        let uuid: UUID
        let news: News

        func updateState(_ state: inout AppState) {

            state.news[uuid]?.selectedNews = news
            
            for uuid in state.news.keys {
                if let index = state.news[uuid]?.news.firstIndex(where: { $0.guid == news.guid }) {
                    state.news[uuid]?.news[index].unread = false
                }
            }
        }
    }
}

struct SettingsState: StateType, Equatable
{
    var sources: [String: Bool] = [:]
    var updateIntervalSeconds: Int = 10

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
                state.settings.sources[source.url] = source.active
            }
        }
    }

    struct RemoveSourceAction: Action
    {
        let sourceURL: String

        func updateState(_ state: inout AppState)
        {
            state.settings.sources[sourceURL] = nil
        }
    }

    struct SetSourceActivityAction: Action
    {
        let sourceURL: String
        let activity: Bool

        func updateState(_ state: inout AppState)
        {
            state.settings.sources[sourceURL] = activity
        }
    }

    struct SetUpdateIntervalAction: Action
    {
        let seconds: Int
        let fromDB: Bool

        func updateState(_ state: inout AppState)
        {
            state.settings.updateIntervalSeconds = max(10, seconds)
        }
    }
}

extension Action {

    func updateState(_ state: inout AppState) { }
}

protocol UIUpdateNews { }
