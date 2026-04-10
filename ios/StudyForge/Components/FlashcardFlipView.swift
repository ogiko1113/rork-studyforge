import SwiftUI

struct FlashcardFlipView: View {
    let frontText: String
    let backText: String
    @Binding var isFlipped: Bool

    var body: some View {
        ZStack {
            cardFace(text: frontText, label: "問題")
                .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
                .opacity(isFlipped ? 0 : 1)

            cardFace(text: backText, label: "答え")
                .rotation3DEffect(.degrees(isFlipped ? 0 : -180), axis: (x: 0, y: 1, z: 0))
                .opacity(isFlipped ? 1 : 0)
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isFlipped)
    }

    private func cardFace(text: String, label: String) -> some View {
        VStack(spacing: 16) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(1)

            Spacer()

            Text(text)
                .font(.title2.weight(.medium))
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)

            Spacer()

            if !isFlipped {
                Text("タップして答えを見る")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .frame(height: 280)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
    }
}
