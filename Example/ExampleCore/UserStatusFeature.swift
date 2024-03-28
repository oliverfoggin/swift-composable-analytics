import ComposableAnalytics
import ComposableArchitecture
import SwiftUI

public enum UserStatus: Equatable {
    case premium
    case standard
    
    var title: String {
        switch self {
        case .premium:
            return "Premium"
            
        case .standard:
            return "Standard"
        }
    }
    
    var opposite: Self {
        switch self {
        case .premium:
            return .standard
            
        case .standard:
            return .premium
        }
    }
}

@Reducer
public struct UserStatusFeature: Reducer {
    @ObservableState
    public struct State: Equatable {
        public var status: UserStatus = .standard
        
        public init() {}
    }
    
    public enum Action: Equatable {
        case toggleStatus
    }
    
    public var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            guard case .toggleStatus = action else {
                return .none
            }

            state.status = state.status.opposite
            return .none
        }
    }
}

public struct UserStatusView: View {
    let store: StoreOf<UserStatusFeature>
    
    public init(
        store: StoreOf<UserStatusFeature>
    ) {
        self.store = store
    }
    
    public var body: some View {
        VStack {
            Text("User Status: \(store.status.title)")
            Button("Toggle Statuss", action: { store.send(.toggleStatus) })
        }
    }
}

#Preview {
    UserStatusView(
        store: .init(
            initialState: .init(),
            reducer: {
                UserStatusFeature()
                    ._printChanges()
            }
        )
    )
}
