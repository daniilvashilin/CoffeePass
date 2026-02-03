import SwiftUI

struct MenuView: View {
    @State private var searchText: String = ""
    var body: some View {
        
        NavigationStack {
            ZStack {
                Color.backGround
                    .ignoresSafeArea(.all)
                VStack {
                    Text("Searching for \(searchText)")
                        .navigationTitle("Menu")
                }
                .searchable(text: $searchText)
            }
        }
    }
}

#Preview {
    MenuView()
}
