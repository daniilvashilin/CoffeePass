import Observation
import FirebaseAuth

@Observable
final class AuthService: AuthServicing {
    
    func signInAsGuest() async throws -> SessionState {
        let result = try await Auth.auth().signInAnonymously()
        return .asGuest(userId: result.user.uid)
    }
    
   
    func restoreSession() async -> SessionState {
        guard let user = Auth.auth().currentUser else {
            return .signedOut
        }
        if user.isAnonymous {
            return .asGuest(userId: user.uid)
        } else {
            return .appleUser(userId: user.uid) // позже, когда будет Apple
        }
    }
    
    func signOut() throws {
            try Auth.auth().signOut()
        }
}
