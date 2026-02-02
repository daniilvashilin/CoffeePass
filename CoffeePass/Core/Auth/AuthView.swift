import SwiftUI
import AuthenticationServices

struct AuthView: View {
    @Environment(AppContainer.self) private var container
    @State private var vm: AuthViewModel
    
    init(container: AppContainer) {
        _vm = State(initialValue: AuthViewModel(authService: container.authService, appState: container.appState))
    }
    var body: some View {
        ZStack {
            Color.backGround.edgesIgnoringSafeArea(.all)
            VStack {
                
                SignInWithAppleButton(.continue) { response in
                    // Soon
                } onCompletion: { completion in
                    // Soon
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .signInWithAppleButtonStyle(.whiteOutline)
                
                Button("Enter guest mode") {
                    Task {await vm.authGueste()}
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding()
        }
    }
}
//#Preview {
//    AuthView()
//}



