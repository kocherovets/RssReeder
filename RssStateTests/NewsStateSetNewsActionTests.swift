//
//  AppendNewsActionTests.swift
//  AppendNewsActionTests
//
//  Created by Dmitry Kocherovets on 21.09.2020.
//

import XCTest
@testable import RssState

class NewsStateSetNewsActionTests: XCTestCase {

    fileprivate static let date1 = Date().removeTime()
    fileprivate static let date2 = date1.addingTimeInterval(-60 * 60 * 24)

    fileprivate let sourceURL = "sourceURL"

    fileprivate static let time1 = date1.addingTimeInterval(1000)
    fileprivate static let time2 = date2.addingTimeInterval(1000)
    fileprivate static let time3 = date2.addingTimeInterval(500)

    fileprivate let article1 = NewsState.Article(source: "source1",
                                                 guid: "giud1",
                                                 title: "title1",
                                                 body: "body1",
                                                 time: time1,
                                                 imageURL: "imageURL1",
                                                 unread: true,
                                                 starred: false)
    fileprivate let article2 = NewsState.Article(source: "source2",
                                                 guid: "giud2",
                                                 title: "title2",
                                                 body: "body2",
                                                 time: time2,
                                                 imageURL: "imageURL2",
                                                 unread: true,
                                                 starred: false)
    fileprivate let article3 = NewsState.Article(source: "source3",
                                                 guid: "giud3",
                                                 title: "title3",
                                                 body: "body3",
                                                 time: time3,
                                                 imageURL: "imageURL3",
                                                 unread: false,
                                                 starred: false)
    fileprivate let uuid = UUID()

    fileprivate func createState() -> AppState {
        var state = AppState()
        state.news[uuid] = NewsState()
        return state
    }

    fileprivate func days() -> [NewsState.DayArticles] {
        [
            NewsState.DayArticles(date: Self.date1, articles: [article1]),
            NewsState.DayArticles(date: Self.date2, articles: [article2, article3])
        ]
    }

    func test1() {

        let initState = createState()
        var state = initState

        let action = NewsState.SetNewsAction(newsUUID: uuid,
                                             days: [NewsState.DayArticles]())
        action.updateState(&state)

        XCTAssertEqual(state.news[uuid]?.days, [NewsState.DayArticles]())

        state.news[uuid]?.days =  [NewsState.DayArticles]()

        XCTAssertEqual(initState, state)
    }

    func test2() {

        let initState = createState()
        var state = initState

        let action = NewsState.SetNewsAction(newsUUID: uuid,
                                             days: days())
        action.updateState(&state)

        XCTAssertEqual(state.news[uuid]?.days, days())

        state.news[uuid]?.days =  [NewsState.DayArticles]()

        XCTAssertEqual(initState, state)
    }
}
