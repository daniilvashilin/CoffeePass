import SwiftUI

@main
struct CoffeePassApp: App {
    private let container = AppContainer()
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(container)
        }
    }
}
