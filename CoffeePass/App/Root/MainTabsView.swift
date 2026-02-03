import SwiftUI

struct MainTabsView: View {
    private let container: AppContainer

    init(container: AppContainer) {
        self.container = container
    }
    var body: some View {
        @Bindable var appState = container.appState

        TabView(selection: $appState.selectedTab) {
            Tab("Home", systemImage: "house", value: MainTabFlow.home) {
                HomeView(container: container)
            }

            Tab("Menu", systemImage: "cup.and.saucer", value: MainTabFlow.menu) {
                MenuView()
            }

            Tab("Game", systemImage: "gamecontroller", value: MainTabFlow.game) {
                GameView()
            }
        }
    }
}
