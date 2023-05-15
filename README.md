# Composable Analytics

A composable, decoupled and testable way to add analytics to any TCA project without getting the analytics and working code tangled up together.

* [Basic Usage](#basic-usage)
* [Custom Analytics Clients](#custom-analytics-clients)
* [Testing](#testing)
* [Installation](#installation)

## Basic Usage

Composable Analytics provides an `AnalyticsReducer` which provides all the working logic for unwrapping and sending your analytics events to the `@Dependency(\.analyticsClient)` in your project. By default the `analyticsClient` dependency is set to `unimplemented` so first you should add the dependency to your store.

At the entry point of your app when you first create the `Store` you can update the analytics here. This package provides a `.consoleLogger` client and you can add your own too.

```swift
Store(
  initialState: App.State(),
  reducer: App()
    .dependency(\.analyticsClient, AnalyticsClient.consoleLogger)
)
```

Then in any `Reducer` within the app you can add an `AnalyticsReducer` to the `body`. This is created with a function that takes `state` and `action` and returns an optional `AnalyticsData`.

```swift
struct App: Reducer {
  struct State {
    var title: String
  }

  enum Action {
    case buttonTapped
  }

  var body: some ReducerOf<Self> {
    AnalyticsReducer { state, action in
      // state here is immutable so there is no way for your analytics to interfere with your app.
      switch action {
      case .buttonTapped:
        return  .event(name: "AppButtonTapped", properties: ["title": state.title])
      }
    }
  
    Reduce<State, Action> { state, action in
      // your normal app logic sits here unchanged
    }
  }
}
```

This keeps all of your analytics out of your working code but still in a place that makes it easy to see and reason about what analytics your app is sending.

As most analytics will probably be events without any properties the `AnalyticsData` is expressible by string literal. So, `.event(name: "SomeName")` and `"SomeName"` are equivalent.

As a personal preference,  I tend to use `default: return nil` at the end of it. `nil` is returned from the `AnalyticsReducer` for any action/state combination when you don't want it to send analytics. So it is a lot more convenient to wrap them all up in a `default` case at the end of the switch rather than list out all the actions and return `nil` from each.

## Custom Analytics Clients

This package only provides an analytics client for logging to the console. Accessible as `AnalyticsClient.consoleLogger` but you can very easily add your own custom clients.

For example, you may want to log analytics to Firebase. In which case you can add your own clients be extending `AnalyticsClient`...

```swift
import Firebase
import FirebaseCrashlytics
import ComposableAnalytics

public extension AnalyticsClient {
  static var firebaseClient: Self {
    return .init(
      sendAnalytics: { analyticsData in
        switch analyticsData {
        case let .event(name: name, properties: properties):
          Firebase.Analytics.logEvent(name, parameters: properties)

        case .userId(let id):
          Firebase.Analytics.setUserID(id)
          Crashlytics.crashlytics().setUserID(id)

        case let .userProperty(name: name, value: value):
          Firebase.Analytics.setUserProperty(value, forName: name)

        case .screen(name: let name):
          Firebase.Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: name
          ])

        case .error(let error):
          Crashlytics.crashlytics().record(error: error)
        }
      }
    )
  }
}
```

This could be your Firebase implementation. Which you then add to the store by merging with any other clients you want to use...

```swift
let analytics = AnalyticsClient.merge(
  // this merges multiple analytics clients into a single instance
  .consoleLogger,
  .firebaseClient
)

Store(
  initialState: App.State(),
  reducer: App()
    .dependency(\.analyticsClient, analytics)
)
```

## Testing

This leans into the TCA way of testing. Because all your analytics are sent using Effects. This package provides an `expect` function that can be used to easily tell your test which analytics you are expecting during a test...

```swift
import XCTest
import ComposableArchitecture
@testable import App

@MainActor
class AppTests: XCTestCase {
  func testButtonTap() async throws {
    let store = TestStore(
      initialState: App.State.init(title: "Hello, world!"),
      reducer: App()
    )

    store.dependencies.analyticsClient.expect(
      .event(name: "AppButtonTapped", properties: ["title": "Hello, world!"])
    )

    await store.send(.buttonTapped)
  }
}
```

This expectation is exhaustive.

It will fail if the analytics is expected and not received. And it will fail if you receive analytics that you did not expect.

## Installation

You can add ComposableAnalytics to your project by adding `https://github.com/oliverfoggin/swift-composable-analytics` into the SPM packages for your project.
