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
    public struct State: Equatable {
        public var counter: CounterFeature.State
        public var userStatus: UserStatusFeature.State
        
        public init() {
            self.counter = .init()
            self.userStatus = .init()
        }
    }
    
    public enum Action: Equatable {
        case task
        case counter(CounterFeature.Action)
        case userStatus(UserStatusFeature.Action)
    }
    
    @Dependency(\.analyticsClient) var analyticsClient
    
    public var body: some Reducer<State, Action> {
        /// The `onChange` modifier only applies to the reducer you chain onto it with.
        /// Source: https://github.com/pointfreeco/swift-composable-architecture/issues/2488
        CombineReducers {
            Scope(state: \.userStatus, action: \.userStatus) {
                UserStatusFeature()
            }
            
            Scope(state: \.counter, action: \.counter) {
                CounterFeature()
            }
            
            Reduce<State, Action> { state, action in
                switch action {
                case .task:
                    return .run { _ in
                        analyticsClient.sendAnalytics(.user(id: "user-1"))
                        analyticsClient.sendAnalytics(.event(name: "app-start"))
                    }
                    
                case .counter:
                    return .none
                    
                case .userStatus:
                    return .none
                }
            }
        }
        .analyticsOnChange(client: self.analyticsClient, of: \.userStatus.status) { prev, new in
            .event(
                name: "user-status",
                parameter: [
                    "from": prev.title,
                    "to": new.title
                ]
            )
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
        VStack {
            UserStatusView(
                store: store.scope(state: \.userStatus, action: \.userStatus)
            )
            
            CounterFeatureView(
                store: store.scope(state: \.counter, action: \.counter)
            )
        }
        .task {
            store.send(.task)
        }
    }
}

#Preview {
    AppFeatureView(store: appStore)
}

