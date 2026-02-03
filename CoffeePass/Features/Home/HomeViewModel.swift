import Observation
import Foundation

@MainActor
@Observable
final class HomeViewModel {

    private let authService: AuthServicing
    private let firestore: FirestoreServicing

    var points: Int = 0
    var tierTitle: String = ""
    var errorMessage: String?

    private var loyaltyListener: AnyObject?

    init(authService: AuthServicing, firestore: FirestoreServicing) {
        self.authService = authService
        self.firestore = firestore
    }

    func start() {
        guard let uid = authService.currentUserUID else {
            errorMessage = "No user session"
            return
        }

        loyaltyListener = firestore.listenLoyaltyAccount(uid: uid) { [weak self] result in
            guard let self = self else { return }

            Task { @MainActor in
                switch result {
                case .success(let account):
                    self.points = account?.points ?? 0
                    self.tierTitle = account?.tier.rawValue ?? ""
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func stop() {
        loyaltyListener = nil
    }
}
