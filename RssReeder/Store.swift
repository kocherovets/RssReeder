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

    var sources: [String: Bool] = [:]
    var updateIntervalSeconds: Int = 10

    var news = [News]()

    var error = StateError.none
}

enum StateError: Error, Equatable {
    case none
    case error(String)
}

extension Action {

    func updateState(_ state: inout AppState) { }
}

protocol UIUpdateNews { }

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

    struct SetHideBodyAction: Action, UIUpdateNews
    {
        let value: Bool

        func updateState(_ state: inout AppState)
        {
            state.hideBody = value
        }
    }

    struct SetNewsAction: Action, UIUpdateNews
    {
        let news: [News]

        func updateState(_ state: inout AppState)
        {
            state.news = news
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
                state.sources[source.url] = source.active
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
            state.sources[sourceURL] = activity
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
    
    struct SelectNewsAction: Action, UIUpdateNews {

        let news: State.News

        func updateState(_ state: inout AppState) {
            
            state.selectedNews = news

            if let index = state.news.firstIndex(where: { $0.guid == news.guid }) {

                state.news[index].unread = false
            }
        }
    }
}
