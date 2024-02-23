import ComposableArchitecture
@testable import Example
import XCTest

@MainActor
final class ExampleTests: XCTestCase {
    func testAppFeatureOnStartReceivesAnalytics() async {
        let store = TestStore(
            initialState: AppFeature.State(),
            reducer: {
                AppFeature()
            },
            withDependencies: {
                $0.analyticsClient = .consoleLogger
            }
        )
        
        store.dependencies.analyticsClient.expect(
            .user(id: "user-1")
        )
        
        store.dependencies.analyticsClient.expect(
            .event(name: "app-start")
        )
        
        await store.send(.task).finish()
    }
    
    func testAppFeatureReceivesUserAnalytics() async {
        let store = TestStore(
            initialState: AppFeature.State(),
            reducer: {
                AppFeature()
            },
            withDependencies: {
                $0.analyticsClient = .consoleLogger
            }
        )
        
        store.dependencies.analyticsClient.expect(
            .event(
                name: "user-status",
                parameter: [
                    "from": UserStatus.standard.title,
                    "to": UserStatus.premium.title
                ]
            )
        )
        
        let task = await store.send(.userStatus(.toggleStatus)) {
            $0.userStatus.status = .premium
        }
        
        await task.finish()
    }
    
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
