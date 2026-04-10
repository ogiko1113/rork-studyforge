import SwiftUI

struct DeckProgressBar: View {
    let deckName: String
    let newCount: Int
    let learningCount: Int
    let masteredCount: Int

    private var total: Int {
        newCount + learningCount + masteredCount
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(deckName)
                .font(.subheadline.weight(.medium))

            GeometryReader { geo in
                let width = geo.size.width
                HStack(spacing: 1) {
                    if masteredCount > 0 {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(AppColors.mastered)
                            .frame(width: max(2, width * CGFloat(masteredCount) / CGFloat(total)))
                    }
                    if learningCount > 0 {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(AppColors.learning)
                            .frame(width: max(2, width * CGFloat(learningCount) / CGFloat(total)))
                    }
                    if newCount > 0 {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(AppColors.newCard.opacity(0.4))
                            .frame(width: max(2, width * CGFloat(newCount) / CGFloat(total)))
                    }
                }
            }
            .frame(height: 8)
            .clipShape(.rect(cornerRadius: 4))

            HStack(spacing: 12) {
                legendItem(color: AppColors.mastered, label: "習得 \(masteredCount)")
                legendItem(color: AppColors.learning, label: "学習中 \(learningCount)")
                legendItem(color: AppColors.newCard.opacity(0.4), label: "新規 \(newCount)")
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 3) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text(label)
        }
    }
}
