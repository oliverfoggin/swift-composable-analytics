public protocol AnalyticClientProtocol {
    associatedtype DataType
    var sendAnalytics: @Sendable (DataType) -> Void { get set }
}

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

#if DEBUG
extension AnalyticClientProtocol where DataType: Equatable {
    public mutating func expect(_ expectedAnalytics: DataType?) {
        let fulfill = expectation(description: "analytics")
        self.sendAnalytics = { @Sendable [self] analytics in
            if let expectedAnalytics, analytics == expectedAnalytics {
                fulfill()
            } else {
                self.sendAnalytics(analytics)
            }
        }
    }
}
#endif
