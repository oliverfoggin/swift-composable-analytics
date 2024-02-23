import ComposableArchitecture
@testable import Example
import XCTest

@MainActor
final class ExampleTests: XCTestCase {
    func testCounterIncrementReceivesAnalytics() async {
        let store = TestStore(
            initialState: CounterFeature.State(),
            reducer: {
                CounterFeature()
            },
            withDependencies: {
                $0.analyticsClient = .consoleLogger
            }
        )
        
        let task = await store.send(.task)
        
        store.dependencies.analyticsClient.expect(
            .event(name: "increment-tapped", parameter: ["count": "1"])
        )
        
        await store.send(.incrementTapped) {
            $0.count = 1
        }
        
        await task.finish()
    }
    
    func testCounterDecrementReceivesAnalytics() async {
        let store = TestStore(
            initialState: CounterFeature.State(),
            reducer: {
                CounterFeature()
            },
            withDependencies: {
                $0.analyticsClient = .consoleLogger
            }
        )
        
        let task = await store.send(.task)
        
        store.dependencies.analyticsClient.expect(
            .event(name: "decrement-tapped", parameter: ["count": "-1"])
        )
        
        await store.send(.decrementTapped) {
            $0.count = -1
        }
        
        await task.finish()
    }
}
