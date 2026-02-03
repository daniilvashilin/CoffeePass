import SwiftUI
import AuthenticationServices

struct UserSettingsView: View {
    @Environment(AppContainer.self) private var container
    @State private var vm: AuthViewModel

    init(container: AppContainer) {
        _vm = State(initialValue: AuthViewModel(
            authService: container.authService, firestore: container.firestoreService,
            appState: container.appState,
            nonceProvider: container.nonce
        ))
    }

    var body: some View {
        List {
            // MARK: Account
            Section {
                if container.appState.session.canLinkAppleAccount {
                    AppleLinkButtonView(vm: vm)
                } else {
                    AppleLinkedStatusView()
                }

                if vm.isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
            }

            // MARK: Preferences
            Section("Preferences") {
                NavigationLink {
                    AppearanceView()
                } label: {
                    SettingsValueRow(title: "Appearance", value: AppearanceOption.currentTitle)
                }

                NavigationLink {
                    DisplayNameUser() // заглушка пока Firestore
                } label: {
                    SettingsValueRow(title: "Display name", value: "Daniel (stub)")
                }
            }

            // MARK: Support
            Section("Support") {
                NavigationLink {
                    SupportView()
                } label: {
                    SettingsRow(title: "Help & Support", systemImage: "questionmark.circle")
                }
            }

            // MARK: Legal
            Section("Legal") {
                NavigationLink {
                    PolicyView()
                } label: {
                    SettingsRow(title: "Privacy Policy", systemImage: "hand.raised")
                }

                NavigationLink {
                    TermsView()
                } label: {
                    SettingsRow(title: "Terms of Service", systemImage: "doc.text")
                }
            }

            // MARK: About
            Section("About") {
                SettingsValueRow(title: "Version", value: AppVersion.current)
                    .foregroundStyle(.secondary)
            }
            
            Section {
                Button(role: .destructive) {
                    Task {
                        await vm.signOut()
                    }
                } label: {
                    Text("Sign Out")
                }
            }
            
            
        }
        .scrollContentBackground(.hidden)
        .background(Color.backGround)
        .navigationTitle("Settings")
    }
}

struct SettingsRow: View {
    let title: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .frame(width: 22)
                .foregroundStyle(.secondary)
            Text(title)
            Spacer()
        }
    }
}

struct SettingsValueRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value).foregroundStyle(.secondary)
        }
    }
}


