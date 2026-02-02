import Observation
import SwiftUI
import AuthenticationServices

@MainActor
@Observable
final class AuthViewModel {
    var errorMessage: String?
    var isLoading: Bool = false
    private let authService: AuthServicing
    private let appState: AppState
    private let nonceProvider: NonceProviding
    
    private var currentRawNonce: String?
    
    init(authService: AuthServicing, appState: AppState, nonceProvider: NonceProviding) {
        self.authService = authService
        self.appState = appState
        self.nonceProvider = nonceProvider
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
    
    func prepareAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        let rawNonce = nonceProvider.makeNonce()
        currentRawNonce = rawNonce
        
        request.requestedScopes = [.fullName, .email]
        request.nonce = nonceProvider.sha256(rawNonce)
    }
    
    func handleAppleCompletion(_ result: Result<ASAuthorization, Error>) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let auth = try result.get()
            
            guard let appleCredential = auth.credential as? ASAuthorizationAppleIDCredential else {
                throw NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid Apple credential"])
            }
            guard let rawNonce = currentRawNonce else {
                throw NSError(domain: "Auth", code: -3, userInfo: [NSLocalizedDescriptionKey: "Missing nonce"])
            }
            
            let session = try await authService.signInWithApple(credential: appleCredential, rawNonce: rawNonce)
            appState.applySession(session)
            
            currentRawNonce = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
