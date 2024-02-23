import Foundation
import ComposableArchitecture

public extension AnalyticClientProtocol {
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
