import SwiftUI

struct LoyaltyCardSection: View {
    let points: Int
    let rankTitle: String

    var body: some View {
        VStack(spacing: 16) {
            LoyaltyCardView(points: points, rankTitle: rankTitle)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }
}

// MARK: - Card

struct LoyaltyCardView: View {
    let points: Int
    let rankTitle: String

    var body: some View {
        ZStack {
            AnimatedShimmerBackground()
                .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))

            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(.black.opacity(0.20))

            content
                .padding(18)

            highlight
                .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                .blendMode(.screen)
                .opacity(0.55)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .strokeBorder(.white.opacity(0.20), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.25), radius: 18, x: 0, y: 10)

        .aspectRatio(1.62, contentMode: .fit)

        .frame(minHeight: 190, maxHeight: 240)
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("CoffeePass")
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(.white.opacity(0.92))

                    Text("LOYALTY CARD")
                        .font(.system(.caption, design: .rounded).weight(.semibold))
                        .tracking(1.2)
                        .foregroundStyle(.white.opacity(0.75))
                }
                .textScale(TopSafeAreaPolicy.shouldIgnoreTop ? .secondary : .default)
                Spacer()

                RankBadge(title: rankTitle)
            }

            Spacer(minLength: 10)

            HStack(alignment: .lastTextBaseline) {
                Text("\(points)")
                    .font(.system(size: 46, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .textScale(TopSafeAreaPolicy.shouldIgnoreTop ? .secondary : .default)
                
                Text("stars")
                    .font(.system(.title3, design: .rounded).weight(.semibold))
                    .foregroundStyle(.white.opacity(0.85))
                    .textScale(TopSafeAreaPolicy.shouldIgnoreTop ? .secondary : .default)

                Spacer()
            }

            HStack(spacing: 10) {
                Image(systemName: "sparkles")
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
                    .foregroundStyle(.white.opacity(0.85))
                    .textScale(TopSafeAreaPolicy.shouldIgnoreTop ? .secondary : .default)
                
                Text("Scan your QR at the bar to earn rewards")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.white.opacity(0.80))
                    .lineLimit(2)
                    .textScale(TopSafeAreaPolicy.shouldIgnoreTop ? .secondary : .default)

                Spacer()
            }
        }
    }

    private var highlight: some View {
        RadialGradient(
            colors: [
                .white.opacity(0.55),
                .white.opacity(0.16),
                .clear
            ],
            center: .topLeading,
            startRadius: 10,
            endRadius: 500
        )
    }
}

// MARK: - Animated background

struct AnimatedShimmerBackground: View {
    var body: some View {
        TimelineView(.animation) { context in
            let t = context.date.timeIntervalSinceReferenceDate
            let phase = CGFloat((sin(t * 0.45) + 1) / 2) // 0...1

            let start = UnitPoint(x: 0.10 + 0.35 * phase, y: 0.10)
            let end   = UnitPoint(x: 0.90, y: 0.75 - 0.25 * phase)

            LinearGradient(
                colors: [
                    Color(red: 0.13, green: 0.12, blue: 0.16),
                    Color(red: 0.45, green: 0.25, blue: 0.70),
                    Color(red: 0.10, green: 0.70, blue: 0.80),
                    Color(red: 0.90, green: 0.55, blue: 0.25),
                    Color(red: 0.12, green: 0.12, blue: 0.16)
                ],
                startPoint: start,
                endPoint: end
            )
            .hueRotation(.degrees(Double(phase) * 18))
            .saturation(1.18)
            .contrast(1.05)
        }
    }
}

// MARK: - Rank badge

struct RankBadge: View {
    let title: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "crown.fill")
                .font(.system(.caption, design: .rounded).weight(.semibold))
            Text(title.uppercased())
                .font(.system(.caption, design: .rounded).weight(.bold))
                .tracking(1.0)
        }
        .foregroundStyle(.white.opacity(0.92))
        .textScale(TopSafeAreaPolicy.shouldIgnoreTop ? .secondary : .default)
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(.white.opacity(0.14))
        .clipShape(Capsule())
        .overlay(
            Capsule().strokeBorder(.white.opacity(0.18), lineWidth: 1)
        )
    }
}

// MARK: - Preview

#Preview("iPhone 13 mini width") {
    LoyaltyCardSection(points: 128, rankTitle: "Gold")
        .padding()
        .frame(width: 375)
        .background(Color.backGround)
}
