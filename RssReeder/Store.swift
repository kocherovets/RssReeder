import Foundation
import RedSwift

struct AppState: RootStateType, Equatable
{
    var news = [UUID: NewsState]()
    var settings = SettingsState()
    var error = StateError.none

    enum Routing: Equatable {
        case none
        case showsArticle(uuid: UUID)
    }
    var lastRouting = Routing.none

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
    case unknownDBError
}

extension Action {
    func updateState(_ state: inout AppState) { }
}

protocol UINews { }
protocol UIArticle { }

struct NewsState: StateType, Equatable
{
    struct Article: Equatable {
        var source: String
        var guid: String
        var title: String
        var body: String
        var time: Date
        var imageURL: String
        var unread: Bool
        var starred: Bool
    }
    var hideBody = false
    var showsStarredOnly = false
    var selectedNews: Article?
    struct DayArticles: Equatable
    {
        var date: Date
        var articles: [NewsState.Article]
    }
    var days = [NewsState.DayArticles]()

    struct AddNewsStateAction: Action, UINews
    {
        let uuid: UUID

        func updateState(_ state: inout AppState)
        {
            state.news[uuid] = NewsState()
        }
    }

    struct SetHideBodyAction: Action, UINews, ThrottleAction
    {
        let uuid: UUID
        let value: Bool

        func updateState(_ state: inout AppState)
        {
            state.news[uuid]?.hideBody = value
        }
    }

    struct SetNewsAction: Action, UINews, LogMaxItems
    {
        let uuid: UUID
        let days: [NewsState.DayArticles]

        func updateState(_ state: inout AppState)
        {
            state.news[uuid]?.days = days
        }
        
        var logMaxItems: Int { 17 }
    }

    struct SelectNewsAction: Action, UINews, UIArticle, ThrottleAction {

        let uuid: UUID
        let news: Article

        func updateState(_ state: inout AppState) {

            state.lastRouting = .showsArticle(uuid: uuid)
            state.news[uuid]?.selectedNews = news

            let date = news.time.removeTime()
            for uuid in state.news.keys {
                if
                    let dayIndex = state.news[uuid]?.days.firstIndex(where: { $0.date == date }),
                    let index = state.news[uuid]?.days[dayIndex].articles.firstIndex(where: { $0.guid == news.guid })
                {
                    state.news[uuid]?.days[dayIndex].articles[index].unread = false
                }
            }
        }
    }

    struct SetStarAction: Action, UINews, UIArticle, ThrottleAction
    {
        let news: Article
        let starred: Bool

        func updateState(_ state: inout AppState)
        {
            let date = news.time.removeTime()
            for uuid in state.news.keys {
                if
                    let dayIndex = state.news[uuid]?.days.firstIndex(where: { $0.date == date }),
                    let index = state.news[uuid]?.days[dayIndex].articles.firstIndex(where: { $0.guid == news.guid })
                {
                    state.news[uuid]?.days[dayIndex].articles[index].starred = starred
                }
                if state.news[uuid]?.selectedNews?.guid == news.guid {
                    state.news[uuid]?.selectedNews?.starred = starred
                }
            }
        }
    }

    struct ShowsOnlyStarredAction: Action, UINews, ThrottleAction
    {
        let uuid: UUID
        let value: Bool

        func updateState(_ state: inout AppState)
        {
            state.news[uuid]?.showsStarredOnly = value
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

    struct SetSourceActivityAction: Action, ThrottleAction
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
