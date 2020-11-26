import UIKit
import RedSwift
import FeedKit

class UpdateNewsInteractor: Interactor<AppState>
{
    typealias Dependencies = UpdateNewsInteractor
    
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
        func condition(box: StateBox<AppState>) -> Bool
        {
            box.lastAction is TimerInteractor.RestartTimerSE.FinishAction
        }

        func execute(box: StateBox<AppState>, trunk: Trunk, interactor: Dependencies)
        {
            for source in box.state.settings.sources.keys {

                if let feedURL = URL(string: source) {

                    let parser = FeedParser(URL: feedURL)
                    parser.parseAsync(queue: DispatchQueue.global(qos: .userInitiated)) { (result) in

                        switch result
                        {
                        case .success(let feed):
                            if
                                let rssFeed = feed.rssFeed,
                                let items = rssFeed.items {

                                let news = items.map { item -> NewsState.Article in

                                    NewsState.Article(
                                        source: rssFeed.title ?? "",
                                        guid: item.guid?.value ?? UUID().uuidString,
                                        title: item.title ?? "",
                                        body: item.description ?? "",
                                        time: item.pubDate ?? Date.distantPast,
                                        imageURL: item.enclosure?.attributes?.url ?? "",
                                        unread: true,
                                        starred: false)
                                }
                                trunk.dispatch(ToDBInteractor.SetNewsSE.StartAction(sourceURL: source, news: news))
                            }
                        case .failure(let error):
                            trunk.dispatch(AppState.ErrorAction(error: StateError.error(error.localizedDescription)))
                        }
                    }
                }
            }
        }
    }
}
