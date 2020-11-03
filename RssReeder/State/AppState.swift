import Foundation
import RedSwift

struct AppState: RootStateType, Equatable
{
    var news = [UUID: NewsState]()
    var settings = SettingsState()

    enum Routing: Equatable
    {
        case none
        case showsArticle(uuid: UUID)
    }
    var lastRouting = Routing.none

    var error = StateError.none
}

enum StateError: Error, Equatable
{
    case none
    case error(String)
    case unknownDBError
}

extension AppState
{
    struct ErrorAction: Action
    {
        let error: StateError

        func updateState(_ state: inout AppState)
        {
            state.error = error
        }
    }
}

extension Action
{
    func updateState(_ state: inout AppState) { }
}
