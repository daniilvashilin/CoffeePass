import SwiftUI

struct MenuView: View {
    @State private var searchText: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.backGround.ignoresSafeArea()

                VStack(spacing: 16) {
                    Text("Searching for \(searchText)")
                        .foregroundStyle(.primary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle("Menu")
            .navigationBarTitleDisplayMode(TopSafeAreaPolicy.shouldIgnoreTop ? .inline : .large)
            .searchable(text: $searchText)
        }
    }
}

