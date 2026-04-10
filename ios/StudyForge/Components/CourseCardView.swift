import SwiftUI

struct CourseCardView: View {
    let courseName: String
    let deckCount: Int
    let totalDue: Int
    let totalCards: Int

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(AppColors.accent.gradient)
                .frame(width: 4, height: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(courseName)
                    .font(.headline)
                    .foregroundStyle(.primary)

                HStack(spacing: 12) {
                    Label("\(deckCount)デッキ", systemImage: "rectangle.stack")
                    Label("\(totalCards)枚", systemImage: "rectangle.portrait.on.rectangle.portrait")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            if totalDue > 0 {
                Text("\(totalDue)")
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
