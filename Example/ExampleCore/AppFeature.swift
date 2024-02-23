import ComposableAnalytics
import ComposableArchitecture
import SwiftUI

public let appStore = StoreOf<AppFeature>(
    initialState: AppFeature.State(),
    reducer: {
        AppFeature()
    }
)

@Reducer
public struct AppFeature: Reducer {
    @ObservableState
    public struct State: Equatable {
        public var counter: CounterFeature.State
        
        public init() {
            self.counter = .init()
        }
    }
    
    public enum Action: Equatable {
        case task
        case counter(CounterFeature.Action)
    }
    
    @Dependency(\.analyticsClient) var analyticsClient
    
    public var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case .task:
                return .run { _ in
                    analyticsClient.sendAnalytics(.user(id: "user-1"))
                    analyticsClient.sendAnalytics(.event(name: "app-start"))
                }
                
            case .counter:
                return .none
            }
        }
        
        Scope(state: \.counter, action: \.counter) {
            CounterFeature()
        }
    }
}

public struct AppFeatureView: View {
    let store: StoreOf<AppFeature>
    
    public init(
        store: StoreOf<AppFeature>
    ) {
        self.store = store
    }
    
    public var body: some View {
        CounterFeatureView(
            store: store.scope(state: \.counter, action: \.counter)
        )
        .task {
            store.send(.task)
        }
    }
}

#Preview {
    AppFeatureView(
        store: .init(
            initialState: .init(),
            reducer: {
                AppFeature()
                    ._printChanges()
            }
        )
    )
}

