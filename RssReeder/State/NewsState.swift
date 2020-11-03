import Foundation
import RedSwift

protocol UINews { }
protocol UIArticle { }

struct NewsState: StateType, Equatable
{
    struct Article: Equatable
    {
        var source: String
        var guid: String
        var title: String
        var body: String
        var time: Date
        var imageURL: String
        var unread: Bool
        var starred: Bool
    }
    var selectedArticle: Article?
    
    struct DayArticles: Equatable
    {
        var date: Date
        var articles: [NewsState.Article]
    }
    var days = [NewsState.DayArticles]()
    
    var hideBody = false
    var showsStarredOnly = false
}

extension NewsState
{
    fileprivate mutating func read(article: Article)
    {
        let date = article.time.removeTime()
        if
            let dayIndex = days.firstIndex(where: { $0.date == date }),
            let index = days[dayIndex].articles.firstIndex(where: { $0.guid == article.guid })
        {
            days[dayIndex].articles[index].unread = false
        }
    }
    
    fileprivate mutating func set(starred: Bool, for article: Article)
    {
        let date = article.time.removeTime()
        if
            let dayIndex = days.firstIndex(where: { $0.date == date }),
            let index = days[dayIndex].articles.firstIndex(where: { $0.guid == article.guid })
        {
            days[dayIndex].articles[index].starred = starred
        }
        if selectedArticle?.guid == article.guid
        {
            selectedArticle?.starred = starred
        }
    }
}

extension NewsState
{
    struct SetNewsAction: Action, UINews, LogMaxItems
    {
        let newsUUID: UUID
        let days: [NewsState.DayArticles]

        func updateState(_ state: inout AppState)
        {
            state.news[newsUUID]?.days = days
        }
        
        var logMaxItems: Int { 17 }
    }
    
    struct AddNewsStateAction: Action, UINews
    {
        let newsUUID: UUID

        func updateState(_ state: inout AppState)
        {
            state.news[newsUUID] = NewsState()
        }
    }

    struct SetHideBodyAction: Action, UINews, ThrottleAction
    {
        let newsUUID: UUID
        let value: Bool

        func updateState(_ state: inout AppState)
        {
            state.news[newsUUID]?.hideBody = value
        }
    }

    struct SelectNewsAction: Action, UINews, UIArticle, ThrottleAction
    {
        let newsUUID: UUID
        let article: Article

        func updateState(_ state: inout AppState)
        {
            state.lastRouting = .showsArticle(uuid: newsUUID)
            state.news[newsUUID]?.selectedArticle = article

            for uuid in state.news.keys
            {
                state.news[uuid]?.read(article: article)
            }
        }
    }

    struct SetStarAction: Action, UIArticle, ThrottleAction
    {
        let article: Article
        let starred: Bool

        func updateState(_ state: inout AppState)
        {
            for uuid in state.news.keys
            {
                state.news[uuid]?.set(starred: starred, for: article)
            }
        }
    }

    struct ShowsOnlyStarredAction: Action, ThrottleAction
    {
        let newsUUID: UUID
        let value: Bool

        func updateState(_ state: inout AppState)
        {
            state.news[newsUUID]?.showsStarredOnly = value
        }
    }
}
