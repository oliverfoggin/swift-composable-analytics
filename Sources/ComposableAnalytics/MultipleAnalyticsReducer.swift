import Foundation
import ComposableArchitecture

public extension AnalyticsClient {
    /// A reducer that runs to send multiple analytics event data simultaneously.
    ///
    /// This reducer should be composed in the `Reducer.body` in your 
    /// feature to handle multiple analytics events per action:
    ///
    /// ```swift
    /// enum AnalyticDataType {
    ///     case event(name: String, parameter: [String: Int])
    /// }
    ///
    /// @Reducer
    /// struct Feature {
    ///   struct State {
    ///     // Properties...
    ///   }
    ///   enum Action {
    ///     case buttonTapped
    ///     // Other actions...
    ///   }
    ///
    ///   @Dependency(\.analyticsClient) var analyticsClient
    ///
    ///   var body: some ReducerOf<Self> {
    ///     Reduce { state, action in
    ///       // Your feature's logic...
    ///     }
    ///
    ///     analyticsClient.reduceMultiple { state, action in
    ///         switch action {
    ///         case .buttonTapped:
    ///             return [
    ///               AnalyticDataType.event(name: "button-tapped", parameter: ["count": state.count]),
    ///               AnalyticDataType.event(name: "another-event", parameter: ["value": state.value])
    ///             ]
    ///         // Handle other actions...
    ///         }
    ///     }
    ///   }
    /// }
    /// ```
    ///
    /// The `analyticsClient.reduceMultiple` method allows for sending 
    /// multiple analytics events for a single action within your feature's reducer.
    /// It runs after your feature's logic by default,
    /// utilizing the state after changes have been applied.
    /// _If_ you need to capture the state and actions before applying your feature's logic,
    /// consider flipping the composition of your reducers.
    ///
    /// - Parameters:
    ///   - toAnalyticsData: A closure that returns an array of the associated `DataType` 
    ///   or `nil` if no events should be sent.
    ///
    /// - Returns: A reducer that sends multiple analytics events simultaneously.

    @inlinable
    func reduceMultiple<State, Action>(
        _ toAnalyticsData: @escaping (State, Action) -> [DataType]?
    ) -> some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            guard let events = toAnalyticsData(state, action) else { return .none }
            
            return .concatenate(
                events.map { data in
                    .run { _ in self.sendAnalytics(data) }
                }
            )
        }
    }
}
