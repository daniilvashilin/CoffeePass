import SwiftUI


struct DisplayNameUser: View {
    var body: some View {
        ZStack {
            Color.backGround.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 12) {
                Text("Display name")
                    .font(.title2).fontWeight(.semibold)

                Text("Stub for now. Later it will be loaded/saved from Firestore.")
                    .foregroundStyle(.secondary)

                Spacer()
            }
            .padding()
        }
    }
}
