import ComposableArchitecture
import SwiftUI

@main
struct ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            if !_XCTIsTesting {
                AppFeatureView(store: appStore)
            }
        }
    }
}
