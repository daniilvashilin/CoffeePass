import SwiftUI

struct RootView: View {
    @Environment(AppContainer.self) private var container

    var body: some View {
        Group {
            switch container.appState.flow {
            case .loading:
                EmptyView()

            case .entryChoice:
                AuthView(container: container)

            case .main:
                MainTabsView(container: container)

            case .onBoarding:
                EmptyView()
            }
        }
        .task {
            await container.appState.bootstrap(auth: container.authService)
        }
    }
}
