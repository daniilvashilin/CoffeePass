import Foundation

struct LoyaltyAccount: Codable, Equatable {
    let userId: String           // uid
    var points: Int              // starts
    var tier: Tier               // ranks

    var createdAt: Date?
    var updatedAt: Date?

    enum Tier: String, Codable, Equatable {
        case bronze
        case silver
        case gold
        case platinum
    }
}

extension LoyaltyAccount {
    static func initial(userId: String) -> LoyaltyAccount {
        LoyaltyAccount(
            userId: userId,
            points: 0,
            tier: .bronze,
            createdAt: nil,
            updatedAt: nil
        )
    }
}
