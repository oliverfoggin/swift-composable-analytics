import Foundation
import ComposableArchitecture

public extension AnalyticClientProtocol {
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
