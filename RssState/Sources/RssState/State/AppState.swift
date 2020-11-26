import Foundation
import RedSwift

public struct AppState: RootStateType, Equatable
{
    public init() {}
    
    public var news = [UUID: NewsState]()
    public var settings = SettingsState()

    public enum Routing: Equatable
    {
        case none
        case showsArticle(uuid: UUID)
    }
    public var lastRouting = Routing.none

    public var error = StateError.none
}

public enum StateError: Error, Equatable
{
    case none
    case error(String)
    case unknownDBError
}

extension AppState
{
    public struct ErrorAction: Action
    {
        public let error: StateError

        public func updateState(_ state: inout AppState)
        {
            state.error = error
        }
    }
}

extension Action
{
    public func updateState(_ state: inout AppState) { }
}

