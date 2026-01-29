protocol AuthServicing {
    func restoreSession() async -> SessionState
    func signInAsGuest() async throws -> SessionState
    func signOut() throws 
}
