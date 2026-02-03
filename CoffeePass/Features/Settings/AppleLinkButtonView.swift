import SwiftUI
import AuthenticationServices

struct AppleLinkButtonView: View {
    var vm: AuthViewModel
    var body: some View {
        Button {
            startAppleLink()
        } label: {
            HStack {
                Image(systemName: "link")
                VStack(alignment: .leading) {
                    Text("Link Apple ID").font(.headline)
                    Text("To keep your progress across devices")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 72)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
        .disabled(vm.isLoading)
        
    }
    private func startAppleLink() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        vm.prepareAppleRequest(request)
        
        AppleAuthRunner.run(request: request) { result in
            Task { await vm.handleAppleCompletion(result, mode: .link) }
        }
    }
}
