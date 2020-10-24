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
        private var localDate = Date.distantPast
        
        override func reaction(for box: StateBox<AppState>) -> ReactionToState
        {
            if localDate == box.state.lastUpdateTS {
                return .none
            }
            localDate = box.state.lastUpdateTS
            return .props
        }

        override func props(for box: StateBox<AppState>, trunk: Trunk) -> TableProps?
        {
            let rows = box.state.news
                .map { news in
                    return NewsCellVM(
                        source: news.source.uppercased(),
                        title: news.title,
                        body: news.body,
                        hideBody: box.state.hideBody,
                        time: dateFormatter.string(from: news.time),
                        imageURL: news.imageURL,
                        unread: news.unread,
                        selectCommand: Command {
                            trunk.dispatch(RouterInteractor.ShowsNewsItemSE.ShowsAction(news: news))
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
