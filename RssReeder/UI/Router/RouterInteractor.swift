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
        func condition(box: StateBox<AppState>) -> Bool {

            box.lastAction is NewsState.SelectNewsAction
        }

        func execute(box: StateBox<AppState>, trunk: Trunk, interactor: RouterInteractor) {

            if let uuid = (box.lastAction as? NewsState.SelectNewsAction)?.uuid {
                Router.showNewsItem(uuid: uuid)
            }
        }
    }
}
