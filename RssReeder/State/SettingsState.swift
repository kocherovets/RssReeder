import Foundation
import RedSwift

protocol UISettings { }

struct SettingsState: StateType, Equatable
{
    var sources: [String: Bool] = [:]
    var updateIntervalSeconds: Int = 10
}

extension SettingsState
{
    struct AddSourcesAction: Action, UISettings
    {
        struct Info {
            let url: String
            let active: Bool
        }

        let sources: [Info]
        let fromDB: Bool

        func updateState(_ state: inout AppState)
        {
            for source in sources {
                state.settings.sources[source.url] = source.active
            }
        }
    }

    struct RemoveSourceAction: Action, UISettings
    {
        let sourceURL: String

        func updateState(_ state: inout AppState)
        {
            state.settings.sources[sourceURL] = nil
        }
    }

    struct SetSourceActivityAction: Action, ThrottleAction, UISettings
    {
        let sourceURL: String
        let activity: Bool

        func updateState(_ state: inout AppState)
        {
            state.settings.sources[sourceURL] = activity
        }
    }

    struct SetUpdateIntervalAction: Action, UISettings
    {
        let seconds: Int
        let fromDB: Bool

        func updateState(_ state: inout AppState)
        {
            state.settings.updateIntervalSeconds = max(10, seconds)
        }
    }
}
