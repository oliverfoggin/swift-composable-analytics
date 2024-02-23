import Foundation
import ComposableArchitecture

extension Reducer {
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
