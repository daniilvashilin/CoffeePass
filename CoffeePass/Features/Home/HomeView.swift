import SwiftUI

struct HomeView: View {
    @Environment(AppContainer.self) private var container
    var body: some View {
        Text("Home View!")
        Button("Sign Out") {
            Task {
                do {
                    try container.authService.signOut()
                     container.appState.applySession(.signedOut)
                } catch {
                    print(error)
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
