import Foundation
import ComposableArchitecture

public struct AnalyticsReducer<State, Action>: Reducer {
	@usableFromInline
	let toAnalyticsData: (State, Action) -> AnalyticsData?
	
	@usableFromInline
	@Dependency(\.analyticsClient) var analyticsClient
	
	@inlinable
	public init(_ toAnalyticsData: @escaping (State, Action) -> AnalyticsData?) {
		self.init(toAnalyticsData: toAnalyticsData, internal: ())
	}
	
	@usableFromInline
	init(toAnalyticsData: @escaping (State, Action) -> AnalyticsData?, internal: Void) {
		self.toAnalyticsData = toAnalyticsData
	}
	
	@inlinable
	public func reduce(into state: inout State, action: Action) -> Effect<Action> {
		guard let analyticsData = toAnalyticsData(state, action) else {
			return .none
		}

		return .run { _ in
			analyticsClient.sendAnalytics(analyticsData)
		}
	}
}
