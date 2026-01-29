import SwiftUI

struct RootView: View {
    @Environment(\.container) private var container
    var body: some View {
        switch container.appState.flow {
        case .loading: Text("Loading...")
        case .entryChoice: Text("Entry Choice")
        case .onBoarding: Text("On Boarding")
        case .main: Text("Main")
        }
    }
}

#Preview {
    RootView()
}
