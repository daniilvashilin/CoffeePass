import Observation

@Observable
final class AppContainer {
    let authService: AuthServicing
    let appState: AppState
    let nonce: NonceProviding
    let firestoreService: FirestoreServicing
    init(
        appState: AppState = AppState(),
        authService: AuthServicing = AuthService(),
        nonce: NonceProviding = NonceProvider(),
        firestoreService: FirestoreServicing = FirestoreService()
    ) {
        self.appState = appState
        self.authService = authService
        self.nonce = nonce
        self.firestoreService = firestoreService
    }
}
