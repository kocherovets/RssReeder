//
//  UpdateNewsInteractor.swift
//  RssReeder
//
//  Created by Dmitry Kocherovets on 21.09.2020.
//

import UIKit
import RedSwift
import FeedKit

class UpdateNewsInteractor: Interactor<AppState>
{
    override init(store: Store<AppState>)
    {
        super.init(store: store)
    }

    override var sideEffects: [AnySideEffect]
    {
        [
            UpdateNewsSE(),
        ]
    }
}

extension UpdateNewsInteractor
{
    struct UpdateNewsSE: SideEffect
    {
        public struct StartAction: Action {

            func updateState(_ state: inout State) {
            }
        }

        func condition(box: StateBox<AppState>) -> Bool {

            box.lastAction is StartAction
        }

        func execute(box: StateBox<AppState>, trunk: Trunk, interactor: UpdateNewsInteractor) {

            for source in box.state.sources.keys {

                if box.state.sources[source]?.active != true {
                    continue
                }
                if let feedURL = URL(string: source) {

                    let parser = FeedParser(URL: feedURL)
                    parser.parseAsync(queue: DispatchQueue.global(qos: .userInitiated)) { (result) in

                        switch result {
                        case .success(let feed):
                            if
                                let rssFeed = feed.rssFeed,
                                let items = rssFeed.items {

                                    let news = items.map { item -> AppState.News in

                                        AppState.News(sourceURL: source,
                                                   source: rssFeed.title ?? "",
                                                   guid: item.guid?.value ?? UUID().uuidString,
                                                   title: item.title ?? "",
                                                   body: item.description?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
                                                   time: item.pubDate ?? Date.distantPast,
                                                   imageURL: item.enclosure?.attributes?.url ?? "",
                                                   unread: true)
                                    }
                                    trunk.dispatch(SyncToDBInteractor.SetNewsSE.StartAction(sourceURL: source, news: news))
                            }

                        case .failure(let error):
                            print(error)
                        }
                    }
                }
            }
        }
    }
}