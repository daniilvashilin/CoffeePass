import Foundation
import FirebaseFirestore

struct UserModel: Codable, Equatable {
    @DocumentID var id: String?

    var displayName: String
    var email: String?

    var photoURLString: String?

    @ServerTimestamp var createdAt: Date?
    @ServerTimestamp var updatedAt: Date?

    var policyAccepted: Bool
    var termsAccepted: Bool

    var userType: UserType


    var photoURL: URL? { photoURLString.flatMap(URL.init(string:)) }
}

enum UserType: String, Codable, Equatable {
    case user
    case moderator
    case admin
}

extension UserModel {
    static func empty(uid: String) -> UserModel {
        UserModel(
            id: uid,
            displayName: "",
            email: nil,
            photoURLString: nil,
            policyAccepted: false,
            termsAccepted: false,
            userType: .user
        )
    }
}
