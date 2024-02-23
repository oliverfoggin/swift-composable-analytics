import Foundation
import ComposableArchitecture

public extension AnalyticsClient {
    /// A reducer that runs to send analytics event data.
    ///
    /// This reducer should be composed in the `Reducer.body` in your feature:
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
    /// This makes it so that the `analyticsClient.reduce` method is run
    /// after your feature's logic, _i.e._ you will see the state after
    /// the changes have been made in the feature reducer.
    /// If you'd like to respond to actions and the state _before_ the feature
    /// reducer, you can flip the order and run `analyticsClient.reduce` before
    /// your feature logic.
    ///
    /// - Parameters:
    ///   - toAnalyticsData: A closure that returns the associated `DataType`
    ///   or `nil` if no events should be sent.
    ///
    /// - Returns: A reducer that sends analytics events.
    @inlinable
    func reduce<State, Action>(
        _ toAnalyticsData: @escaping (State, Action) -> DataType?
    ) -> some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            guard let event = toAnalyticsData(state, action) 
            else { return .none }
            
            return .run { _ in
                self.sendAnalytics(event)
            }
        }
    }
}
