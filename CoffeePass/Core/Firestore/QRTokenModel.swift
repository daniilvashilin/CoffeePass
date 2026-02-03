import Foundation

struct QRTokenModel: Codable, Equatable {
    let id: String
    let userId: String

    var purpose: Purpose
    var status: Status

    var createdAt: Date?
    var expiresAt: Date?
    var usedAt: Date?


    enum Purpose: String, Codable, Equatable {
        case earnPoints
        case redeemReward
    }

    enum Status: String, Codable, Equatable {
        case active
        case used
        case revoked
    }

    var isUsable: Bool {
        guard status == .active else { return false }
        guard let expiresAt else { return false }
        return Date() < expiresAt
    }
}

extension QRTokenModel {
    static func earnPointsToken(
        id: String,
        userId: String,
        expiresAt: Date
    ) -> QRTokenModel {
        QRTokenModel(
            id: id,
            userId: userId,
            purpose: .earnPoints,
            status: .active,
            createdAt: nil,
            expiresAt: expiresAt,
            usedAt: nil,
        )
    }
}
