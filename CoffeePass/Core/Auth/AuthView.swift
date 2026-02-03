import SwiftUI
import AuthenticationServices

struct AuthView: View {
    private let container: AppContainer
    @State private var vm: AuthViewModel
    
    init(container: AppContainer) {
           self.container = container
           _vm = State(initialValue: AuthViewModel(
            authService: container.authService, firestore: container.firestoreService, appState: container.appState, nonceProvider: container.nonce
           ))
       }
    var body: some View {
        ZStack {
            Color.backGround.ignoresSafeArea()
            VStack {
                
                SignInWithAppleButton(.continue) { request in
                    vm.prepareAppleRequest(request)
                } onCompletion: { result in
                    Task { await vm.handleAppleCompletion(result, mode: .signIn)}
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




