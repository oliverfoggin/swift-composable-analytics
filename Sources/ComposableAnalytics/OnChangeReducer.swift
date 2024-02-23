import Foundation
import ComposableArchitecture

extension Reducer {
    /// Adds analytics reporting to a reducer based on changes in a specific state value.
    ///
    /// This operator allows you to attach analytics events to state changes. 
    /// It's particularly useful for tracking changes in specific parts
    /// of your app's state and sending these events to your analytics backend.
    ///
    /// ```swift
    /// enum AnalyticDataType {
    ///     case event(name: String, parameter: [String: Int])
    /// }
    ///
    /// @Reducer
    /// struct UserProfile {
    ///   struct State {
    ///     var username: String
    ///     // Other state properties...
    ///   }
    ///
    ///   enum Action {
    ///     case usernameChanged(String)
    ///     // Other actions...
    ///   }
    ///
    ///   var body: some ReducerOf<Self> {
    ///     Reduce { state, action in
    ///       // Reducer logic...
    ///     }
    ///     .analyticsOnChange(
    ///         client: analyticsClient,
    ///         of: \.username,
    ///         { oldValue, newValue in
    ///             .event(name: "Username Changed", parameter: ["old": oldValue, "new": newValue])
    ///         }
    ///     )
    ///   }
    /// }
    /// ```
    ///
    /// The `analyticsOnChange` operator works by capturing the specified state value 
    /// before and after the reducer's action is processed.
    /// If the value changes (as determined by the `Equatable` protocol),
    /// it triggers an analytics event by calling the provided analytics event
    /// construction closure with the old and new values.
    ///
    /// - Parameters:
    ///   - client: The analytics client responsible for sending analytics events.
    ///   - of: A closure that extracts the value to monitor from the overall state.
    ///   - toAnalyticsData: A closure that constructs an analytics event (`DataType`) from the 
    ///   old and new values of the monitored state.
    ///
    /// - Returns: A reducer that incorporates analytics tracking into its operation, 
    /// specifically designed to report changes in the monitored state value.
    /// 
    @inlinable
    public func analyticsOnChange<T, V: Equatable>(
        client: AnalyticsClient<T>,
        of toValue: @escaping (State) -> V,
        _ toAnalyticsData: @escaping (V, V) -> T
    ) -> _OnChangeAnalyticsReducer<Self, V, T> {
        _OnChangeAnalyticsReducer(
            client: client,
            base: self,
            toValue: toValue,
            isDuplicate: ==,
            toAnalyticsData: toAnalyticsData
        )
    }
}

public struct _OnChangeAnalyticsReducer<Base: Reducer, Value: Equatable, AnalyticType>: Reducer {
    @usableFromInline
    let base: Base

    @usableFromInline
    let toValue: (Base.State) -> Value

    @usableFromInline
    let isDuplicate: (Value, Value) -> Bool

    @usableFromInline
    let analyticsClient: AnalyticsClient<AnalyticType>
    
    @usableFromInline
    let toAnalyticsData: (Value, Value) -> AnalyticType

    @usableFromInline
    init(
        client: AnalyticsClient<AnalyticType>,
        base: Base,
        toValue: @escaping (Base.State) -> Value,
        isDuplicate: @escaping (Value, Value) -> Bool,
        toAnalyticsData: @escaping (Value, Value) -> AnalyticType
    ) {
        self.analyticsClient = client
        self.base = base
        self.toValue = toValue
        self.isDuplicate = isDuplicate
        self.toAnalyticsData = toAnalyticsData
    }

    @inlinable
    public func reduce(into state: inout Base.State, action: Base.Action) -> Effect<Base.Action> {
        let oldValue = toValue(state)
        let effects = self.base.reduce(into: &state, action: action)
        let newValue = toValue(state)

        return isDuplicate(oldValue, newValue)
        ? effects
        : effects.merge(with: .run { _ in
            analyticsClient.sendAnalytics(toAnalyticsData(oldValue, newValue))
        })
    }
}
