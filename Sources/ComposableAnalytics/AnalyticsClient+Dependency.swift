import Dependencies
import XCTestDynamicOverlay

extension AnalyticsClient {
    static var unimplemented: Self {
        .init(
            sendAnalytics: XCTestDynamicOverlay.unimplemented("\(Self.self).sendAnalytics")
        )
    }
    
    public static var consoleLogger: Self {
        .init(
            sendAnalytics: { val in
                #if DEBUG
                print("[Analytics] ✅ \(val)")
                #endif
            }
        )
    }
}

extension AnalyticsClient: TestDependencyKey {
    public static var testValue:  Self {
        .unimplemented
    }
    
    public static var previewValue: Self {
        .consoleLogger
    }
}
