import SwiftUI

enum TopSafeAreaPolicy {
    static var shouldIgnoreTop: Bool {
        guard
            let scene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first
        else {
            return false
        }

        let bounds = scene.screen.bounds
        let height = max(bounds.height, bounds.width)

        return height <= 812
    }
}

