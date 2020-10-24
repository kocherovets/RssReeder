//
//  AppendNewsActionTests.swift
//  AppendNewsActionTests
//
//  Created by Dmitry Kocherovets on 21.09.2020.
//

import XCTest
@testable import RssReeder

class AppendNewsActionTests: XCTestCase {

    fileprivate let sourceURL = "sourceURL"

    fileprivate let news1 = State.News(sourceURL: "sourceURL1",
                                       source: "source1",
                                       guid: "giud1",
                                       title: "title1",
                                       body: "body1",
                                       time: Date(),
                                       imageURL: "imageURL1",
                                       unread: true)
    fileprivate let news2 = State.News(sourceURL: "sourceURL2",
                                       source: "source2",
                                       guid: "giud2",
                                       title: "title2",
                                       body: "body2",
                                       time: Date().addingTimeInterval(1000),
                                       imageURL: "imageURL2",
                                       unread: true)
    fileprivate let news3 = State.News(sourceURL: "sourceURL3",
                                       source: "source3",
                                       guid: "giud3",
                                       title: "title3",
                                       body: "body3",
                                       time: Date().addingTimeInterval(2000),
                                       imageURL: "imageURL3",
                                       unread: false)

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test1() {

        var state = State()

        let action = State.AppendNewsAction(sourceURL: sourceURL,
                                            news: [])
        action.updateState(&state)

        XCTAssertEqual(state.sources[sourceURL], nil)
    }

    func test2() {

        var state = State()

        let action = State.AppendNewsAction(sourceURL: sourceURL,
                                            news: [])
        action.updateState(&state)

        XCTAssertEqual(state.sources[sourceURL], nil)
    }

    func test3() {

        var state = State()
        state.sources[sourceURL] = State.SourceInfo()

        let action = State.AppendNewsAction(sourceURL: sourceURL,
                                            news: [])
        action.updateState(&state)

        XCTAssertEqual(state.sources[sourceURL], State.SourceInfo(items: [], active: true))
    }

    func test4() {

        var state = State()
        state.sources[sourceURL] = State.SourceInfo()

        let action = State.AppendNewsAction(sourceURL: sourceURL,
                                            news: [news1])
        action.updateState(&state)

        XCTAssertEqual(state.sources[sourceURL], State.SourceInfo(items: [news1], active: true))
    }

    func test5() {

        var state = State()
        state.sources[sourceURL] = State.SourceInfo(items: [], active: false)

        let action = State.AppendNewsAction(sourceURL: sourceURL,
                                            news: [news1])
        action.updateState(&state)

        XCTAssertEqual(state.sources[sourceURL], State.SourceInfo(items: [news1], active: false))
    }

    func test6() {

        var initState = State()
        var state = initState
        state.sources[sourceURL] = State.SourceInfo()

        let action = State.AppendNewsAction(sourceURL: sourceURL,
                                            news: [news1, news3, news2])
        action.updateState(&state)

        XCTAssertEqual(state.sources[sourceURL], State.SourceInfo(items: [news3, news2, news1], active: true))
        
        initState.sources[sourceURL] = State.SourceInfo(items: [news3, news2, news1], active: true)
        initState.lastUpdateTS = state.lastUpdateTS

        XCTAssertEqual(initState, state)
    }

    func test7() {

        var initState = State()
        var state = initState
        state.sources[sourceURL] = State.SourceInfo(items: [news3, news2, news1], active: true)

        let action = State.AppendNewsAction(sourceURL: sourceURL,
                                            news: [])
        action.updateState(&state)

        XCTAssertEqual(state.sources[sourceURL], State.SourceInfo(items: [news3, news2, news1], active: true))

        initState.sources[sourceURL] = State.SourceInfo(items: [news3, news2, news1], active: true)
        initState.lastUpdateTS = state.lastUpdateTS

        XCTAssertEqual(initState, state)
    }
}
