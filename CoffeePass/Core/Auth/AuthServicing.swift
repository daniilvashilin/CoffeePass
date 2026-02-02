import AuthenticationServices

protocol AuthServicing {
    func signInAsGuest() async throws -> SessionState
    func restoreSession() async -> SessionState
    func signOut() throws

    func signInWithApple(credential: ASAuthorizationAppleIDCredential, rawNonce: String) async throws -> SessionState
    func linkAppleToCurrentUser(credential: ASAuthorizationAppleIDCredential, rawNonce: String) async throws -> SessionState
}
