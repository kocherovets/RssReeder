import Foundation
import RedSwift

public protocol UINews { }
public protocol UIArticle { }

public struct NewsState: StateType, Equatable
{
    public struct Article: Equatable
    {
        public var source: String
        public var guid: String
        public var title: String
        public var body: String
        public var time: Date
        public var imageURL: String
        public var unread: Bool
        public var starred: Bool
    }
    public var selectedArticle: Article?

    public struct DayArticles: Equatable
    {
        public var date: Date
        public var articles: [NewsState.Article]
    }
    public var days = [NewsState.DayArticles]()

    public var hideBody = false
    public var showsStarredOnly = false
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
    public struct SetNewsAction: Action, UINews, LogMaxItems
    {
        public let newsUUID: UUID
        public let days: [NewsState.DayArticles]

        public func updateState(_ state: inout AppState)
        {
            state.news[newsUUID]?.days = days
        }

        public var logMaxItems: Int { 17 }

        public init(newsUUID: UUID, days: [NewsState.DayArticles]) {
            self.newsUUID = newsUUID
            self.days = days
        }
    }

    public struct AddNewsStateAction: Action, UINews
    {
        public let newsUUID: UUID

        public func updateState(_ state: inout AppState)
        {
            state.news[newsUUID] = NewsState()
        }

        public init(newsUUID: UUID) {
            self.newsUUID = newsUUID
        }
    }

    public struct SetHideBodyAction: Action, UINews, ThrottleAction
    {
        public let newsUUID: UUID
        public let value: Bool

        public func updateState(_ state: inout AppState)
        {
            state.news[newsUUID]?.hideBody = value
        }

        public init(newsUUID: UUID, value: Bool) {
            self.newsUUID = newsUUID
            self.value = value
        }
    }

    public struct SelectNewsAction: Action, UINews, UIArticle, ThrottleAction
    {
        public let newsUUID: UUID
        public let article: Article

        public func updateState(_ state: inout AppState)
        {
            state.lastRouting = .showsArticle(uuid: newsUUID)
            state.news[newsUUID]?.selectedArticle = article

            for uuid in state.news.keys
            {
                state.news[uuid]?.read(article: article)
            }
        }
        
        public init(newsUUID: UUID, article: NewsState.Article) {
            self.newsUUID = newsUUID
            self.article = article
        }
    }

    public struct SetStarAction: Action, UIArticle, ThrottleAction
    {
        public let article: Article
        public let starred: Bool

        public func updateState(_ state: inout AppState)
        {
            for uuid in state.news.keys
            {
                state.news[uuid]?.set(starred: starred, for: article)
            }
        }

        public init(article: NewsState.Article, starred: Bool) {
            self.article = article
            self.starred = starred
        }
    }

    public struct ShowsOnlyStarredAction: Action, ThrottleAction
    {
        public let newsUUID: UUID
        public let value: Bool

        public func updateState(_ state: inout AppState)
        {
            state.news[newsUUID]?.showsStarredOnly = value
        }

        public init(newsUUID: UUID, value: Bool) {
            self.newsUUID = newsUUID
            self.value = value
        }
    }
}
