import Observation
import SwiftUI
import AuthenticationServices

@MainActor
@Observable
final class AuthViewModel {
    var errorMessage: String?
    var isLoading: Bool = false

    private let authService: AuthServicing
    private let firestore: FirestoreServicing
    private let appState: AppState
    private let nonceProvider: NonceProviding

    private var currentRawNonce: String?

    enum AppleAuthMode { case signIn, link }

    init(
        authService: AuthServicing,
        firestore: FirestoreServicing,
        appState: AppState,
        nonceProvider: NonceProviding
    ) {
        self.authService = authService
        self.firestore = firestore
        self.appState = appState
        self.nonceProvider = nonceProvider
    }

    // MARK: - Public

    func authGueste() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let session = try await authService.signInAsGuest()
            let uid = try requireFirebaseUID()
            try await firestore.ensureUserAndLoyaltyExist(uid: uid, email: nil, displayName: nil)
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

    func handleAppleCompletion(_ result: Result<ASAuthorization, Error>, mode: AppleAuthMode) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let auth = try result.get()

            guard let appleCredential = auth.credential as? ASAuthorizationAppleIDCredential else {
                throw NSError(
                    domain: "Auth",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Invalid Apple credential"]
                )
            }
            guard let rawNonce = currentRawNonce else {
                throw NSError(
                    domain: "Auth",
                    code: -3,
                    userInfo: [NSLocalizedDescriptionKey: "Missing nonce"]
                )
            }

            let session: SessionState
            switch mode {
            case .signIn:
                session = try await authService.signInWithApple(credential: appleCredential, rawNonce: rawNonce)
            case .link:
                session = try await authService.linkAppleToCurrentUser(credential: appleCredential, rawNonce: rawNonce)
            }

            let uid = try requireFirebaseUID()

            let email = appleCredential.email
            let displayName = appleDisplayName(from: appleCredential)

            try await firestore.ensureUserAndLoyaltyExist(uid: uid, email: email, displayName: displayName)

            appState.applySession(session)
            currentRawNonce = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signOut() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try authService.signOut()
            appState.applySession(.signedOut)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Private helpers

    private func requireFirebaseUID() throws -> String {
        guard let uid = authService.currentUserUID else {
            throw AuthFlowError.noFirebaseUser
        }
        return uid
    }

    private func appleDisplayName(from cred: ASAuthorizationAppleIDCredential) -> String? {
        let name = [cred.fullName?.givenName, cred.fullName?.familyName]
            .compactMap { $0 }
            .joined(separator: " ")
        return name.isEmpty ? nil : name
    }
}

enum AuthFlowError: LocalizedError {
    case noFirebaseUser

    var errorDescription: String? {
        switch self {
        case .noFirebaseUser:
            return "No active Firebase user session after sign-in."
        }
    }
}
