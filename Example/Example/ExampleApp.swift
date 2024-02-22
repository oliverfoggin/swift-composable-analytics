import SwiftUI

@main
struct ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            AppFeatureView(store: appStore)
        }
    }
}
