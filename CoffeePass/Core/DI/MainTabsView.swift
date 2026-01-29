import SwiftUI

struct MainTabsView: View {
    @Environment(AppContainer.self) private var container

    var body: some View {
        @Bindable var appState = container.appState

        TabView(selection: $appState.selectedTab) {
            Tab("Home", systemImage: "house", value: MainTabFlow.home) {
                EmptyView()
            }

            Tab("Menu", systemImage: "cup.and.saucer", value: MainTabFlow.menu) {
                EmptyView()
            }

            Tab("Game", systemImage: "gamecontroller", value: MainTabFlow.game) {
                EmptyView()
            }
        }
    }
}
