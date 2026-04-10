import SwiftUI

struct DeckCardView: View {
    let deckName: String
    let cardCount: Int
    let dueCount: Int

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(deckName)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text("\(cardCount)枚のカード")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if dueCount > 0 {
                Text("\(dueCount)")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(AppColors.accent.gradient)
                    .clipShape(.capsule)
            }

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 12))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
    }
}
