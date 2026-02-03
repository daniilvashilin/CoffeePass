import SwiftUI

struct AppleLinkedStatusView: View {
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.15))
                    .frame(width: 32, height: 32)

                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.green)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Apple ID connected")
                    .font(.headline)

                Text("Your progress is safely synced")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 72)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.green.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.green.opacity(0.25), lineWidth: 1)
        )
        .allowsHitTesting(false)
        .accessibilityLabel("Apple ID connected")
    }
}
