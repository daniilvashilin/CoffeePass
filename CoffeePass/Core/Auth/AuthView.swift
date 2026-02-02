import SwiftUI
import AuthenticationServices

struct AuthView: View {
    @Environment(AppContainer.self) private var container
    @State private var vm: AuthViewModel
    
    init(container: AppContainer) {
        _vm = State(initialValue: AuthViewModel(authService: container.authService, appState: container.appState, nonceProvider: container.nonce))
    }
    var body: some View {
        ZStack {
            Color.backGround.edgesIgnoringSafeArea(.all)
            VStack {
                
                SignInWithAppleButton(.continue) { request in
                    vm.prepareAppleRequest(request)
                } onCompletion: { result in
                    Task { await vm.handleAppleCompletion(result)}
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .signInWithAppleButtonStyle(.whiteOutline)
                
                Button("Enter guest mode") {
                    Task {await vm.authGueste()}
                }
                .buttonStyle(PrimaryButtonStyle())
                
                if vm.isLoading { ProgressView() }
                if let msg = vm.errorMessage {Text(msg).foregroundColor(.red)}
            }
            .padding()
        }
    }
}




