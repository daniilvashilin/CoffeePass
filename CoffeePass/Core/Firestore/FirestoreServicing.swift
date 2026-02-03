import Foundation

protocol FirestoreServicing: Sendable {

    // MARK: - Bootstrap (login)
    func ensureUserAndLoyaltyExist(uid: String, email: String?, displayName: String?) async throws

    // MARK: - User
    func fetchUser(uid: String) async throws -> UserModel?
    func upsertUser(uid: String, user: UserModel) async throws
    func updateUser(uid: String, fields: [String: Any]) async throws

    func listenUser(uid: String, onChange: @Sendable @escaping (Result<UserModel?, Error>) -> Void) -> AnyObject

    // MARK: - Loyalty
    func fetchLoyaltyAccount(uid: String) async throws -> LoyaltyAccount?
    func listenLoyaltyAccount(uid: String, onChange: @Sendable @escaping (Result<LoyaltyAccount?, Error>) -> Void) -> AnyObject

    // MARK: - QR Tokens
    func createQRToken(_ token: QRTokenModel) async throws
    func fetchQRToken(id: String) async throws -> QRTokenModel?
    func revokeQRToken(id: String) async throws

    // MARK: - Redeem via QR (atomic)
    /// Atomically marks token as used and applies loyalty points change (earn or redeem).
    func redeemQRToken(
        tokenId: String,
        performedBy employeeUid: String,
        points: Int
    ) async throws
}
