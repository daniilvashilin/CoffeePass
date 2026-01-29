import Observation

@Observable
final class AuthService: AuthServicing {
    func loginGuest() {
        // Test
    }
    
    func restoreSession() async -> SessionState {
        return .signedOut
    }
}
