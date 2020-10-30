//
//  AppendNewsActionTests.swift
//  AppendNewsActionTests
//
//  Created by Dmitry Kocherovets on 21.09.2020.
//

import XCTest
@testable import RssReeder

class NewsStateSetNewsActionTests: XCTestCase {

    fileprivate static let date1 = Date().removeTime()
    fileprivate static let date2 = date1.addingTimeInterval(-60 * 60 * 24)

    fileprivate let sourceURL = "sourceURL"

    fileprivate static let time1 = date1.addingTimeInterval(1000)
    fileprivate static let time2 = date2.addingTimeInterval(1000)
    fileprivate static let time3 = date2.addingTimeInterval(500)

    fileprivate let news1 = NewsState.Article(source: "source1",
                                           guid: "giud1",
                                           title: "title1",
                                           body: "body1",
                                           time: time1,
                                           imageURL: "imageURL1",
                                           unread: true,
                                           starred: false)
    fileprivate let news2 = NewsState.Article(source: "source2",
                                           guid: "giud2",
                                           title: "title2",
                                           body: "body2",
                                           time: time2,
                                           imageURL: "imageURL2",
                                           unread: true,
                                           starred: false)
    fileprivate let news3 = NewsState.Article(source: "source3",
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

    fileprivate func news() -> [Date: [NewsState.Article]] {
        [
            Self.date1: [news1],
            Self.date2: [news2, news3]
        ]
    }

    func test1() {

        let initState = createState()
        var state = initState
        
        let action = NewsState.SetNewsAction(uuid: uuid,
                                             news: [Date: [NewsState.Article]]())
        action.updateState(&state)

        XCTAssertEqual(state.news[uuid]?.news, [Date: [NewsState.Article]]())

        state.news[uuid]?.news = [Date: [NewsState.Article]]()

        XCTAssertEqual(initState, state)
    }
    
    func test2() {

        let initState = createState()
        var state = initState
        
        let action = NewsState.SetNewsAction(uuid: uuid,
                                             news: news())
        action.updateState(&state)

        XCTAssertEqual(state.news[uuid]?.news, news())

        state.news[uuid]?.news = [Date: [NewsState.Article]]()

        XCTAssertEqual(initState, state)
    }
}
