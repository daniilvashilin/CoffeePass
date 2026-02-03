import SwiftUI
import AuthenticationServices

struct AuthView: View {
    private let container: AppContainer
    @State private var vm: AuthViewModel

    init(container: AppContainer) {
        self.container = container
        _vm = State(initialValue: AuthViewModel(
            authService: container.authService,
            firestore: container.firestoreService,
            appState: container.appState,
            nonceProvider: container.nonce
        ))
    }

    var body: some View {
        ZStack {
            Color.backGround
                .ignoresSafeArea()

            VStack {
                Spacer()

                header

                Spacer()

                actions

                Spacer(minLength: 24)

                footer
            }
            .padding(.horizontal, 24)
        }
    }
}

private extension AuthView {
    var header: some View {
        VStack(spacing: 12) {
            Image(systemName: "cup.and.saucer.fill")
                .font(.system(size: 44, weight: .semibold))
                .foregroundStyle(.white)

            Text("CoffeePass")
                .font(.system(.largeTitle, design: .rounded).weight(.bold))
                .foregroundStyle(.white)

            Text("Your loyalty, brewed daily")
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(.white.opacity(0.75))
        }
        .multilineTextAlignment(.center)
    }
}

private extension AuthView {
    var actions: some View {
        VStack(spacing: 16) {
            SignInWithAppleButton(.continue) { request in
                vm.prepareAppleRequest(request)
            } onCompletion: { result in
                Task {
                    await vm.handleAppleCompletion(result, mode: .signIn)
                }
            }
            .frame(height: 52)
            .signInWithAppleButtonStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            divider

            Button {
                Task { await vm.authGueste() }
            } label: {
                Text("Continue as Guest")
                    .font(.system(.headline, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
            }
            .buttonStyle(.bordered)
            .tint(.white.opacity(0.85))
        }
    }
}

private extension AuthView {
    var divider: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(.white.opacity(0.2))
                .frame(height: 1)

            Text("or")
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(.white.opacity(0.6))

            Rectangle()
                .fill(.white.opacity(0.2))
                .frame(height: 1)
        }
    }
}

private extension AuthView {
    var footer: some View {
        VStack(spacing: 12) {
            if vm.isLoading {
                ProgressView()
                    .tint(.white)
            }

            if let msg = vm.errorMessage {
                Text(msg)
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }
        }
        .animation(.easeInOut, value: vm.isLoading)
        .animation(.easeInOut, value: vm.errorMessage)
    }
}
