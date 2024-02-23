import Dependencies
import ComposableAnalytics

public enum AnalyticEvent {
    case event(name: String, parameter: [String: String] = [:])
    case user(id: String, parameters: [String: String] = [:])
}

extension AnalyticEvent: Equatable {}

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
            .otherAnalytics
        )
    }
    
    public static var googleAnalytics: AnalyticEventClient {
        AnalyticEventClient(
            sendAnalytics: { event in
                print("Sending to Google -- ", event)
            }
        )
    }
    
    public static var otherAnalytics: AnalyticEventClient {
        AnalyticEventClient(
            sendAnalytics: { event in
                print("Sending to Other Service -- ", event)
            }
        )
    }
}
