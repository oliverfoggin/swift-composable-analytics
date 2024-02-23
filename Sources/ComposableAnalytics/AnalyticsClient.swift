public protocol AnalyticClientProtocol {
    associatedtype DataType
    var sendAnalytics: @Sendable (DataType) -> Void { get set }
}

/// A generic analytics client for sending analytics events.
///
/// This struct encapsulates the functionality required to send 
/// analytics data from your application to a specified analytics service.
/// It is designed to be flexible and generic,
/// allowing you to define the type of analytics data that will be sent.
///
/// Usage involves creating an instance of `AnalyticsClient` with a closure 
/// that handles the actual transmission of analytics data to your analytics backend or service.
/// This design allows for easy integration with various analytics services and custom data types.
///
/// Example:
///
/// ```swift
/// struct AnalyticsEvent {
///     let name: String
///     let parameters: [String: Any]
/// }
///
/// typealias AnalyticEventClient = AnalyticsClient<AnalyticsEvent>
///
/// let analyticsClient = AnalyticEventClient { event in
///     // Implementation to send `event` to an analytics service
///     print("Sending analytics event: \(event.name) with parameters: \(event.parameters)")
/// }
///
/// extension AnalyticEventClient: DependencyKey {
///     static var liveValue: AnalyticsClient {
///         analyticsClient
///     }
/// }
///
/// extension DependencyValues {
///    var analyticsClient: AnalyticEventClient {
///        get { self[AnalyticsClient.self] }
///        set { self[AnalyticsClient.self] = newValue }
///    }
/// }
///
/// @Reducer
/// struct Feature {
///   struct State {
///     // Properties...
///   }
///   enum Action {
///     case incrementTapped
///     case decrementTapped
///   }
///
///   // The live implementation, constrained to a `AnalyticDataType`.
///   @Dependency(\.analyticsClient) var analyticsClient
///
///   var body: some ReducerOf<Self> {
///     Reduce { state, action in
///       // Your feature's logic...
///     }
///
///     analyticsClient.reduce { state, action in
///         switch action {
///         case .incrementTapped:
///             return AnalyticDataType.event(name: "increment-tapped", parameter: ["count": state.count])
///
///         case .decrementTapped:
///             return AnalyticDataType.event(name: "decrement-tapped", parameter: ["count": state.count])
///         }
///     }
///   }
/// }
/// ```
///
/// - Parameters:
///   - sendAnalytics: A closure that defines how analytics data of type `T` is sent to an analytics backend. 
///   This closure is marked as `@Sendable` to ensure it can be safely used in concurrent environments.
///
public struct AnalyticsClient<T>: AnalyticClientProtocol {
	public var sendAnalytics: @Sendable (T) -> Void

	public init(sendAnalytics: @escaping @Sendable (T) -> Void) {
		self.sendAnalytics = sendAnalytics
	}
}

extension AnalyticsClient {
	public static func merge(_ clients: Self...) -> Self {
		.init { data in
			clients.forEach { $0.sendAnalytics(data) }
		}
	}
}

