import Observation
import AuthenticationServices
import FirebaseAuth

@Observable
final class AuthService: AuthServicing {

    func signInAsGuest() async throws -> SessionState {
        let result = try await Auth.auth().signInAnonymously()
        return .asGuest(userId: result.user.uid)
    }

    func restoreSession() async -> SessionState {
        guard let user = Auth.auth().currentUser else { return .signedOut }
        if user.isAnonymous { return .asGuest(userId: user.uid) }
        return .appleUser(userId: user.uid)
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    func signInWithApple(credential appleCredential: ASAuthorizationAppleIDCredential, rawNonce: String) async throws -> SessionState {
        let firebaseCredential = try makeFirebaseAppleCredential(from: appleCredential, rawNonce: rawNonce)
        let result = try await Auth.auth().signIn(with: firebaseCredential)
        return .appleUser(userId: result.user.uid)
    }

    func linkAppleToCurrentUser(credential appleCredential: ASAuthorizationAppleIDCredential, rawNonce: String) async throws -> SessionState {
        let firebaseCredential = try makeFirebaseAppleCredential(from: appleCredential, rawNonce: rawNonce)
        guard let user = Auth.auth().currentUser else { return .signedOut }
        let result = try await user.link(with: firebaseCredential)
        return .appleUser(userId: result.user.uid)
    }

    private func makeFirebaseAppleCredential(from appleCredential: ASAuthorizationAppleIDCredential, rawNonce: String) throws -> AuthCredential {
        guard let tokenData = appleCredential.identityToken,
              let idTokenString = String(data: tokenData, encoding: .utf8)
        else {
            throw NSError(domain: "Auth", code: -2, userInfo: [NSLocalizedDescriptionKey: "Missing Apple identityToken"])
        }

        return OAuthProvider.credential(
            providerID: .apple,
            idToken: idTokenString,
            rawNonce: rawNonce
        )
    }
}
