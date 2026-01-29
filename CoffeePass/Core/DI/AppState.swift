import Observation

@Observable
final class AppState {
    var flow: AppFlow = .loading
    var session: sessionState = .signedOut
    var selectedTab: MainTabFlow = .home
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

enum sessionState: Equatable {
    case signedOut
    case asGuest(userId: String)
    case appleUser(userId: String)
}
