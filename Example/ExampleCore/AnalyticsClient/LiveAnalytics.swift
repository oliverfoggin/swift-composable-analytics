import Dependencies
import ComposableAnalytics

public typealias AnalyticEventClient = AnalyticsClient<AnalyticEvent>

public extension DependencyValues {
    var analyticsClient: AnalyticEventClient {
        get { self[AnalyticsClient.self] }
        set { self[AnalyticsClient.self] = newValue }
    }
}

extension AnalyticEventClient: DependencyKey {
    public static var liveValue: AnalyticsClient {
        .merge(
            .googleAnalytics,
            .crashlytics
        )
    }
    
    /// Here we could define our implementation for Google Analytics
    public static var googleAnalytics: AnalyticEventClient {
        AnalyticEventClient(
            sendAnalytics: { event in
                switch event {
                case .event(let name, let parameter):
                    print("[FIREBASE] EVENT", name, parameter)
                    
                case .user(let id, let parameters):
                    print("[FIREBASE] USER", id, parameters)
                }
            }
        )
    }
    
    public static var crashlytics: AnalyticEventClient {
        AnalyticEventClient(
            sendAnalytics: { event in
                switch event {
                case .event(let name, let parameter):
                    break
                case .user(let id, let parameters):
                    print("[CRASHLYTICS] USER", id, parameters)
                }
            }
        )
    }
}
