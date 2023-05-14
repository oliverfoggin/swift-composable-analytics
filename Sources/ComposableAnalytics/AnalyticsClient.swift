import Foundation
import XCTestDynamicOverlay

public struct AnalyticsClient {
	public var sendAnalytics: @Sendable (AnalyticsData) -> Void

	public init(sendAnalytics: @escaping @Sendable (AnalyticsData) -> Void) {
		self.sendAnalytics = sendAnalytics
	}
}

extension AnalyticsClient {
	public static func merge(_ clients: AnalyticsClient...) -> Self {
		.init { data in
			clients.forEach { $0.sendAnalytics(data) }
		}
	}
}

extension AnalyticsClient {
	static var unimplemented: Self = Self(
		sendAnalytics: XCTUnimplemented("\(Self.self).sendAnalytics")
	)

	public static var consoleLogger: Self = .init(
		sendAnalytics: { analytics in
#if DEBUG
			print("[Analytics] ✅ \(analytics)")
#endif
		}
	)
}

#if DEBUG
extension AnalyticsClient {
	public mutating func expect(_ expectedAnalytics: AnalyticsData?) {
		let fulfill = expectation(description: "analytics")
		self.sendAnalytics = { @Sendable [self] analytics in
			if analytics == expectedAnalytics {
				fulfill()
			} else {
				self.sendAnalytics(analytics)
			}
		}
	}
}
#endif
