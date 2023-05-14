import ComposableArchitecture

extension AnalyticsClient: DependencyKey {
	public static let liveValue: AnalyticsClient = .unimplemented
	public static let testValue: AnalyticsClient = .unimplemented
	public static let previewValue: AnalyticsClient = .consoleLogger
}

public extension DependencyValues {
	var analyticsClient: AnalyticsClient {
		get { self[AnalyticsClient.self] }
		set { self[AnalyticsClient.self] = newValue }
	}
}
