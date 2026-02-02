import Observation
import SwiftUI

@MainActor
@Observable
final class AuthViewModel {
    var errorMessage: String?
    var isLoading: Bool = false
    let authService: AuthServicing
    let appState: AppState
    
    init(authService: AuthServicing, appState: AppState) {
        self.authService = authService
        self.appState = appState
    }
    
    func authGueste() async {
        isLoading = true
        errorMessage = nil
        defer {isLoading = false}
        do {
            let session = try await authService.signInAsGuest()
            appState.applySession(session)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
 
}
