//
//  ArticleView.swift
//  RssSwiftUI
//
//  Created by Dmitry Kocherovets on 07.11.2020.
//

import SwiftUI
import DITranquillity
import RedSwift
import ReduxVM
import Combine
import DeclarativeTVC
import RssState

struct ArticleView: View {

    struct Props: SwiftUIProperties {
        var rightBarButtonImageName = "star"
        var starCommand = Command { }
        var article = NewsState.Article(
            source: "www.washingtontimes.com stories: Politics",
            guid: "https://www.washingtontimes.com/news/2020/nov/6/mark-meadows-tests-positive-coronavirus-reports/?utm_source=RSS_Feed&utm_medium=RSS",
            title: "Mark Meadows tests positive for coronavirus: Reports",
            body: "WASHINGTON &mdash; President Donald Trump\'s chief of staff Mark Meadows has been diagnosed with the coronavirus as the nation sets daily records for confirmed cases for the pandemic. Two senior administration officials confirmed Friday that Meadows had tested positive for the virus, which has killed more than 236,000 Americans so ...",
            time: Date(),
            imageURL: "https://twt-thumbs.washtimes.com/media/image/2020/10/26/Trump_92332.jpg-658e8_s1440x960.jpg?f72536d07237fdd262042ae8f5e6e6de3b865f3c",
            unread: true,
            starred: false)
    }

    class Presenter: SwiftUIPresenter<AppState, Props> {

        required init(store: Store<AppState>) {
            super.init(store: store)
            qq += 1
            print("qq = \(qq)")
        }

        deinit {
            print("deinit")
            qq -= 1
            print("qq = \(qq)")
        }

        override func reaction(for box: StateBox<AppState>) -> ReactionToState
        {
            box.lastAction is UIArticle ? .props : .none
        }

        var uuid: UUID?

        override func props(for box: StateBox<AppState>, trunk: Trunk) -> Props {

            if uuid == nil, case .showsArticle(let uuid) = box.state.lastRouting {
                self.uuid = uuid
            }
            guard
                let uuid = uuid,
                let selectedArticle = box.state.news[uuid]?.selectedArticle else
            {
                return Props()
            }

            return Props(
                rightBarButtonImageName: selectedArticle.starred ? "star.fill" : "star",
                starCommand: Command {
                    trunk.dispatch(NewsState.SetStarAction(article: selectedArticle, starred: !selectedArticle.starred))
                },
                article: selectedArticle
            )
        }
    }

    var dateFormatter: DateFormatter = {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, dd MMMM yyyy, HH:mm"
        return dateFormatter
    }()

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading) {
                Text(dateFormatter.string(from: props.article.time).uppercased())
                    .font(.callout)
                    .foregroundColor(Color(red: 0.8, green: 0.8, blue: 0.8))
                    .padding([.bottom], 1)
                    .padding([.top], 16)
                Text(props.article.title)
                    .font(.title2)
                    .bold()
                    .foregroundColor(Color.black)
                    .padding([.bottom], 1)
                Text(props.article.source.uppercased())
                    .font(.callout)
                    .foregroundColor(Color(red: 0.8, green: 0.8, blue: 0.8))
                    .padding([.bottom], 20)
                Text(props.article.body)
                    .font(.callout)
                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                    .padding([.bottom], 1)
            }
        }
            .padding([.leading, .trailing], 16)
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarItems(
                trailing: Button(action: { props.starCommand.perform() },
                                 label: {
                                     Image(systemName: props.rightBarButtonImageName)
                                         .foregroundColor(Color(red: 1, green: 204.0 / 255.0, blue: 0))
                                 }))
            .onAppear() { presenter.subscribe() }
            .onDisappear { presenter.unsubscribe() }
    }

//    init(presenter: Presenter? = nil, articleUUID: UUID? = nil) {
//        _presenter = StateObject(wrappedValue: presenter ?? Presenter(store: store))
////        self.presenter.uuid = articleUUID
//    }

    @StateObject var presenter = Presenter(store: store)
    var props: Props { testProps ?? presenter.props }
    var testProps: Props? = nil
}

struct ArticleView_Previews: PreviewProvider {
    static var previews: some View {
        ArticleView()
    }
}
