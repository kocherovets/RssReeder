//
//  RouterInteractor.swift
//  RssReeder
//
//  Created by Dmitry Kocherovets on 21.09.2020.
//

import UIKit
import RedSwift

class RouterInteractor: Interactor<AppState>
{
    override init(store: Store<AppState>)
    {
        super.init(store: store)
    }

    override var sideEffects: [AnySideEffect]
    {
        [
            ShowsNewsItemSE(),
        ]
    }
}

extension RouterInteractor
{
    struct ShowsNewsItemSE: SideEffect
    {
        struct ShowsAction: Action {

            let news: State.News

            func updateState(_ state: inout AppState) {
                
                state.selectedNews = news
                
                if let index = state.sources[news.sourceURL]?.items.firstIndex(where: { $0.guid == news.guid }) {
                    
                    state.sources[news.sourceURL]?.items[index].unread = false
                }
            }
        }

        func condition(box: StateBox<AppState>) -> Bool {
            
            box.lastAction is ShowsAction
        }

        func execute(box: StateBox<AppState>, trunk: Trunk, interactor: RouterInteractor) {
            
            Router.showNewsItem()
        }
    }
}
