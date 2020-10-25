//
//  ToolsTVC.swift
//  SwiftTrading
//
//  Created by Dmitry Kocherovets on 21.09.2020.
//  Copyright © 2020 Dmitry Kocherovets. All rights reserved.
//

import Foundation
import ReduxVM
import DITranquillity
import RedSwift
import DeclarativeTVC

enum NewsTVCModule
{
    class Presenter: PresenterBase<AppState, TableProps, ViewController>
    {
        private var firstPass = true
        func isFirstPass() -> Bool {
            let result = firstPass
            firstPass = false
            return result
        }

        var uuid: UUID?

        override func onInit(state: AppState, trunk: Trunk) {

            if let uuid = uuid
            {
                trunk.dispatch(NewsState.AddNewsStateAction(uuid: uuid))
            }
        }

        override func reaction(for box: StateBox<AppState>) -> ReactionToState
        {
            if isFirstPass() || box.lastAction is UIUpdateNews {
                return .props
            }
            return .none
        }

        override func props(for box: StateBox<AppState>, trunk: Trunk) -> TableProps?
        {
            guard
                let uuid = uuid,
                let newsState = box.state.news[uuid] else {
                return nil
            }

            let rows = newsState.news
                .map { news in
                return NewsCellVM(
                    source: news.source.uppercased(),
                    title: news.title,
                    body: news.body,
                    hideBody: newsState.hideBody,
                    time: dateFormatter.string(from: news.time),
                    imageURL: news.imageURL,
                    unread: news.unread,
                    selectCommand: Command {
                        trunk.dispatch(NewsState.SelectNewsAction(uuid: uuid, news: news))
                    })
            }

            return TableProps(tableModel: TableModel(rows: rows))
        }

        var dateFormatter: DateFormatter = {

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            return dateFormatter
        }()
    }
}

class NewsTVC: TVC, PropsReceiver
{
    typealias Props = TableProps
}

extension NewsTVCModule
{
    typealias ViewController = NewsTVC

    class DI: DIPart
    {
        static func load(container: DIContainer)
        {
            container.register(ViewController.self)
                .injection(\ViewController.presenter) {
                $0 as Presenter
            }
                .lifetime(.objectGraph)

            container.register(Presenter.init)
                .injection(cycle: true, \Presenter.propsReceiver)
                .lifetime(.objectGraph)
        }
    }
}
