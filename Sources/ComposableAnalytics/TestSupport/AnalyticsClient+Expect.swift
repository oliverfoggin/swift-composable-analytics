#if DEBUG
extension AnalyticsClient where DataType: Equatable {
    /// Sets up an expectation for a specific analytics event to be sent.
    ///
    /// This function is primarily used in tests to assert that specific analytics events
    /// are triggered by actions within the app. By calling `expect` with the expected
    /// `DataType`, you can ensure that your app's analytics are correctly configured
    /// and firing as expected. If the expected analytics event is sent, the expectation
    /// is fulfilled.
    ///
    /// - Parameter expectedAnalytics: The analytics event you expect to be sent.
    ///   This is a value of your app's `DataType` that represents a specific analytics event.
    ///
    /// Given this reducer:
    /// ```swift
    /// @Reducer
    /// struct Feature {
    ///   struct State {
    ///     var count: Int = 0
    ///   }
    ///   enum Action {
    ///     case incrementTapped
    ///     case decrementTapped
    ///   }
    ///
    ///   @Dependency(\.analyticsClient) var analyticsClient
    ///
    ///   var body: some ReducerOf<Self> {
    ///     Reduce { state, action in
    ///       switch action {
    ///       case .incrementTapped:
    ///         state.count += 1
    ///         return .none
    ///       case .decrementTapped:
    ///         state.count -= 1
    ///         return .none
    ///       }
    ///     }
    ///
    ///     analyticsClient.reduce { state, action in
    ///         switch action {
    ///         case .incrementTapped:
    ///             return .event(name: "increment-tapped", parameter: ["count": state.count])
    ///         case .decrementTapped:
    ///             return .event(name: "decrement-tapped", parameter: ["count": state.count])
    ///         }
    ///     }
    ///   }
    /// }
    /// ```
    ///
    /// We can write this test to assert the events are being fired correctly.
    ///
    /// ```swift
    /// @MainActor
    /// final class ExampleTests: XCTestCase {
    ///     func testFeatureAnalytics() async {
    ///         let store = TestStore(
    ///             initialState: Feature.State(),
    ///             reducer: Feature(),
    ///             withDependencies: {
    ///                 $0.analyticsClient = .mock
    ///             }
    ///         )
    ///
    ///         // This test will fail if the event is not sent to the `analyticsClient`
    ///         store.dependencies.analyticsClient.expect(
    ///             .event(name: "increment-tapped", parameter: ["count": 1])
    ///         )
    ///
    ///         await store.send(.incrementTapped).finish()
    ///     }
    /// }
    /// ```
    ///
    /// In this test, `expect` is used to assert that tapping the increment button triggers
    /// an "increment-tapped" analytics event with the expected parameters. This helps
    /// validate that your analytics tracking is correctly implemented in response to user actions.
    ///
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
