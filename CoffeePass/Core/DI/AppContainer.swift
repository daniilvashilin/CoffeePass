import Observation

@Observable
final class AppContainer {
    let authService: AuthServicing
    let appState: AppState
    let nonce: NonceProviding

    init(
        appState: AppState = AppState(),
        authService: AuthServicing = AuthService(),
        nonce: NonceProviding = NonceProvider()
    ) {
        self.appState = appState
        self.authService = authService
        self.nonce = nonce
    }
}
