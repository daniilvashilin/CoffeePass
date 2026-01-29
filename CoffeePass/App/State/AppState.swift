import Observation

@Observable
final class AppState {
    var flow: AppFlow = .loading
    var session: SessionState = .signedOut
    var selectedTab: MainTabFlow = .home
    
    func bootstrap(auth: AuthServicing) async {
        let session = await auth.restoreSession()
        self.session = session
        
        switch session {
        case .signedOut:
            flow = .entryChoice
        case .asGuest, .appleUser:
            flow = .main
        }
    }
}

enum AppFlow {
    case loading
    case onBoarding
    case entryChoice
    case main
}

enum MainTabFlow: Hashable {
    case home
    case menu
    case game
}

enum SessionState: Equatable {
    case signedOut
    case asGuest(userId: String)
    case appleUser(userId: String)
}
