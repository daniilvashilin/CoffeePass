import Observation

@Observable
final class AppContainer {
    let authService: AuthService
    let appState: AppState
    init(
        appState: AppState = AppState(),
        authService: AuthService = AuthService()
    ) {
        self.appState = appState
        self.authService = authService
    }
}
