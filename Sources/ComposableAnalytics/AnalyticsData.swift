public enum AnalyticsData: Equatable {
	case event(name: String, properties: [String: String] = [:])
	case screen(name: String)
	case userId(String)
	case userProperty(name: String, value: String)
	case error(Error)

	public static func == (lhs: AnalyticsData, rhs: AnalyticsData) -> Bool {
		switch (lhs, rhs) {
		case let (.event(lhsName, lhsProps), .event(rhsName, rhsProps)):
			return lhsName == rhsName && lhsProps == rhsProps
		case let (.screen(lhsName), .screen(rhsName)):
			return lhsName == rhsName
		case let (.userId(lhsId), .userId(rhsId)):
			return lhsId == rhsId
		case let (.userProperty(name: lhsName, value: lhsValue), .userProperty(name: rhsName, value: rhsValue)):
			return lhsName == rhsName && lhsValue == rhsValue
		case let (.error(lhsError), .error(rhsError)):
			return lhsError.localizedDescription == rhsError.localizedDescription
		default:
			return false
		}
	}
}

extension AnalyticsData: ExpressibleByStringLiteral {
	public init(stringLiteral value: StringLiteralType) {
		self = .event(name: value, properties: [:])
	}
}
