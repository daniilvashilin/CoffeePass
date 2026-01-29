protocol AuthServicing {
    func loginGuest() //test
    func restoreSession() async -> SessionState
}
