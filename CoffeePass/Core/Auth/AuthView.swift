import SwiftUI

struct AuthView: View {
    @Environment(AppContainer.self) private var container
    var body: some View {
        Button("Enter guest mode") {
            Task {
                do {
                    let session = try await container.authService.signInAsGuest()
                    container.appState.applySession(session)
                } catch {
                    print(error)
                }
            }
        }
    }
}

#Preview {
    AuthView()
}
