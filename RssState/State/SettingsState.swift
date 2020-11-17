import Foundation
import RedSwift

public protocol UISettings { }

public struct SettingsState: StateType, Equatable
{
    public var sources: [String: Bool] = [:]
    public var updateIntervalSeconds: Int = 300
}

extension SettingsState
{
    public struct AddSourcesAction: Action, UISettings
    {
        public struct Info {
            public let url: String
            public let active: Bool

            public init(url: String, active: Bool) {
                self.url = url
                self.active = active
            }
        }

        public let sources: [Info]
        public let fromDB: Bool

        public func updateState(_ state: inout AppState)
        {
            for source in sources {
                state.settings.sources[source.url] = source.active
            }
        }

        public init(sources: [SettingsState.AddSourcesAction.Info], fromDB: Bool) {
            self.sources = sources
            self.fromDB = fromDB
        }
    }

    public struct RemoveSourceAction: Action, UISettings
    {
        public let sourceURL: String

        public func updateState(_ state: inout AppState)
        {
            state.settings.sources[sourceURL] = nil
        }
    
        public init(sourceURL: String) {
            self.sourceURL = sourceURL
        }
    }

    public struct SetSourceActivityAction: Action, ThrottleAction, UISettings
    {
        public let sourceURL: String
        public let activity: Bool

        public func updateState(_ state: inout AppState)
        {
            state.settings.sources[sourceURL] = activity
        }

        public init(sourceURL: String, activity: Bool) {
            self.sourceURL = sourceURL
            self.activity = activity
        }
    }

    public struct SetTempUpdateIntervalAction: Action
    {
        public let seconds: Int

        public func updateState(_ state: inout AppState)
        {
            state.settings.updateIntervalSeconds = seconds
        }
        
        public init(seconds: Int) {
            self.seconds = seconds
        }
    }

    public struct SetUpdateIntervalAction: Action, UISettings
    {
        public let seconds: Int
        public let fromDB: Bool

        public func updateState(_ state: inout AppState)
        {
            state.settings.updateIntervalSeconds = max(10, seconds)
        }
        
        public init(seconds: Int, fromDB: Bool) {
            self.seconds = seconds
            self.fromDB = fromDB
        }
    }
}
