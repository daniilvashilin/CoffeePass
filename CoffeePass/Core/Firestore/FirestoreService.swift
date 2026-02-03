import Foundation
import FirebaseFirestore
import Observation

@Observable
final class FirestoreService: FirestoreServicing {
    
    @ObservationIgnored
    private lazy var db: Firestore = Firestore.firestore()
    
    init() {}

    // MARK: - Paths
    private func userRef(_ uid: String) -> DocumentReference {
        db.collection("users").document(uid)
    }

    private func loyaltyRef(_ uid: String) -> DocumentReference {
        db.collection("loyaltyAccounts").document(uid)
    }

    private func tokenRef(_ tokenId: String) -> DocumentReference {
        db.collection("qrTokens").document(tokenId)
    }

    private func transactionsCol() -> CollectionReference {
        db.collection("loyaltyTransactions")
    }

    // MARK: - Bootstrap
    func ensureUserAndLoyaltyExist(uid: String, email: String?, displayName: String?) async throws {
        let uRef = userRef(uid)
        let uSnap = try await uRef.getDocument()

        if !uSnap.exists {
            var user = UserModel.empty(uid: uid)
            if let email { user.email = email }
            if let displayName { user.displayName = displayName }
            try uRef.setData(from: user, merge: true)
        }

        let lRef = loyaltyRef(uid)
        let lSnap = try await lRef.getDocument()

        if !lSnap.exists {
            let account = LoyaltyAccount.initial(userId: uid)
            try lRef.setData(from: account, merge: true)
        }
    }

    // MARK: - User
    func fetchUser(uid: String) async throws -> UserModel? {
        let snap = try await userRef(uid).getDocument()
        guard snap.exists else { return nil }
        return try decode(UserModel.self, from: snap)
    }

    func upsertUser(uid: String, user: UserModel) async throws {
        var data = try encode(user)
        data["updatedAt"] = FieldValue.serverTimestamp()
        try await userRef(uid).setData(data, merge: true)
    }

    func updateUser(uid: String, fields: [String: Any]) async throws {
        var fields = fields
        fields["updatedAt"] = FieldValue.serverTimestamp()
        try await userRef(uid).updateData(fields)
    }

    func listenUser(uid: String, onChange: @Sendable @escaping (Result<UserModel?, Error>) -> Void) -> AnyObject {
        let reg = userRef(uid).addSnapshotListener { snap, err in
            if let err { onChange(.failure(err)); return }
            guard let snap else { onChange(.success(nil)); return }
            guard snap.exists else { onChange(.success(nil)); return }
            do {
                let model = try self.decode(UserModel.self, from: snap)
                onChange(.success(model))
            } catch {
                onChange(.failure(error))
            }
        }
        return ListenerToken(reg)
    }

    // MARK: - Loyalty
    func fetchLoyaltyAccount(uid: String) async throws -> LoyaltyAccount? {
        let snap = try await loyaltyRef(uid).getDocument()
        guard snap.exists else { return nil }
        return try decode(LoyaltyAccount.self, from: snap)
    }

    func listenLoyaltyAccount(uid: String, onChange: @Sendable @escaping (Result<LoyaltyAccount?, Error>) -> Void) -> AnyObject {
        let reg = loyaltyRef(uid).addSnapshotListener { snap, err in
            if let err { onChange(.failure(err)); return }
            guard let snap else { onChange(.success(nil)); return }
            guard snap.exists else { onChange(.success(nil)); return }
            do {
                let model = try self.decode(LoyaltyAccount.self, from: snap)
                onChange(.success(model))
            } catch {
                onChange(.failure(error))
            }
        }
        return ListenerToken(reg)
    }

    // MARK: - QR Tokens
    func createQRToken(_ token: QRTokenModel) async throws {
        var data = try encode(token)
        data["createdAt"] = FieldValue.serverTimestamp()
        try await tokenRef(token.id).setData(data, merge: true)
    }

    func fetchQRToken(id: String) async throws -> QRTokenModel? {
        let snap = try await tokenRef(id).getDocument()
        guard snap.exists else { return nil }
        return try decode(QRTokenModel.self, from: snap)
    }

    func revokeQRToken(id: String) async throws {
        try await tokenRef(id).updateData([
            "status": "revoked",
            "updatedAt": FieldValue.serverTimestamp()
        ])
    }

    // MARK: - Redeem (atomic)
    func redeemQRToken(tokenId: String, performedBy employeeUid: String, points: Int) async throws {
        guard points > 0 else { throw FirestoreServiceError.invalidPoints }

        let tRef = tokenRef(tokenId)

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            db.runTransaction({ txn, errPtr -> Any? in
                do {
                    let tokenSnap = try txn.getDocument(tRef)
                    guard tokenSnap.exists else { throw FirestoreServiceError.notFound }

                    let status = tokenSnap.get("status") as? String ?? "active"
                    guard status == "active" else { throw FirestoreServiceError.tokenNotUsable }

                    guard let expiresAt = tokenSnap.get("expiresAt") as? Timestamp else {
                        throw FirestoreServiceError.tokenNotUsable
                    }
                    guard expiresAt.dateValue() > Date() else { throw FirestoreServiceError.tokenExpired }

                    let purpose = tokenSnap.get("purpose") as? String ?? "earnPoints"
                    let userId = tokenSnap.get("userId") as? String ?? ""
                    guard !userId.isEmpty else { throw FirestoreServiceError.decodeFailed }

                    let lRef = self.loyaltyRef(userId)
                    let lSnap = try txn.getDocument(lRef)
                    guard lSnap.exists else { throw FirestoreServiceError.notFound }

                    let currentPoints = lSnap.get("points") as? Int ?? 0

                    let delta: Int
                    switch purpose {
                    case "earnPoints":
                        delta = points
                    case "redeemReward":
                        guard currentPoints >= points else { throw FirestoreServiceError.insufficientPoints }
                        delta = -points
                    default:
                        throw FirestoreServiceError.decodeFailed
                    }

                    txn.updateData([
                        "status": "used",
                        "usedAt": FieldValue.serverTimestamp()
                    ], forDocument: tRef)

                    txn.updateData([
                        "points": currentPoints + delta,
                        "updatedAt": FieldValue.serverTimestamp()
                    ], forDocument: lRef)

                    let txDoc = self.transactionsCol().document()
                    txn.setData([
                        "userId": userId,
                        "kind": (delta > 0 ? "earn" : "redeem"),
                        "amount": points,
                        "reason": (purpose == "earnPoints" ? "purchase" : "rewardRedeem"),
                        "performedBy": employeeUid,
                        "createdAt": FieldValue.serverTimestamp()
                    ], forDocument: txDoc)

                    return nil
                } catch {
                    errPtr?.pointee = error as NSError
                    return nil
                }
            }, completion: { _, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            })
        }
    }
}

// MARK: - Helpers

private final class ListenerToken: NSObject {
    private var reg: ListenerRegistration?
    init(_ reg: ListenerRegistration) { self.reg = reg }
    deinit { reg?.remove() }
}

// Encoding/Decoding via JSON -> Dictionary
extension FirestoreService {
    private var encoder: Firestore.Encoder { Firestore.Encoder() }
    private var decoder: Firestore.Decoder { Firestore.Decoder() }

    private func encode<T: Encodable>(_ value: T) throws -> [String: Any] {
        try encoder.encode(value)
    }

    private func decode<T: Decodable>(_ type: T.Type, from snap: DocumentSnapshot) throws -> T {
        let data = snap.data() ?? [:]
        return try decoder.decode(T.self, from: data)
    }
}
enum FirestoreServiceError: Error {
    case notFound
    case tokenNotUsable
    case tokenExpired
    case insufficientPoints
    case decodeFailed
    case invalidPoints
}
