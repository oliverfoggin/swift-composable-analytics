public enum AnalyticEvent {
    case event(name: String, parameter: [String: String] = [:])
    case user(id: String, parameters: [String: String] = [:])
}

extension AnalyticEvent: Equatable {}
