import Foundation

struct LoyaltyTransaction: Codable, Equatable {
    let id: String
    let userId: String

    let kind: Kind
    let amount: Int
    let reason: Reason

    let createdAt: Date?
    let performedBy: String?

    enum Kind: String, Codable, Equatable {
        case earn
        case redeem  
    }

    enum Reason: String, Codable, Equatable {
        case purchase
        case manualAdjustment
        case rewardRedeem
        case bonus
    }
}
