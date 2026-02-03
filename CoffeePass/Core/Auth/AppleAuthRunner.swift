import AuthenticationServices
import UIKit

enum AppleAuthRunner {
    static func run(
        request: ASAuthorizationAppleIDRequest,
        completion: @escaping (Result<ASAuthorization, Error>) -> Void
    ) {
        let coordinator = Coordinator(completion: completion)

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = coordinator
        controller.presentationContextProvider = coordinator

        coordinator.retain()
        controller.performRequests()
    }

    private final class Coordinator: NSObject,
                                     ASAuthorizationControllerDelegate,
                                     ASAuthorizationControllerPresentationContextProviding {
        private let completion: (Result<ASAuthorization, Error>) -> Void
        private static var retained: [Coordinator] = []

        init(completion: @escaping (Result<ASAuthorization, Error>) -> Void) {
            self.completion = completion
        }

        func retain() { Self.retained.append(self) }
        private func releaseSelf() { Self.retained.removeAll { $0 === self } }

        func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
            guard
                let scene = UIApplication.shared.connectedScenes
                    .compactMap({ $0 as? UIWindowScene })
                    .first,
                let window = scene.windows.first(where: { $0.isKeyWindow })
            else {
                fatalError("No active window scene found for Apple Sign In")
            }

            return window
        }

        func authorizationController(controller: ASAuthorizationController,
                                     didCompleteWithAuthorization authorization: ASAuthorization) {
            completion(.success(authorization))
            releaseSelf()
        }

        func authorizationController(controller: ASAuthorizationController,
                                     didCompleteWithError error: Error) {
            completion(.failure(error))
            releaseSelf()
        }
    }
}
