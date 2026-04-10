import SwiftUI

struct StatsView: View {
    @Environment(StudyDataStore.self) private var store

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    summaryGrid
                    weeklyChart
                    deckProgress
                    averageEFSection
                }
                .padding(16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("統計")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var summaryGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            StatCardView(
                title: "総カード数",
                value: "\(store.totalCards)",
                icon: "rectangle.stack.fill",
                color: AppColors.accent
            )
            StatCardView(
                title: "本日の復習数",
                value: "\(store.todayReviewCount)",
                icon: "clock.fill",
                color: .orange
            )
            StatCardView(
                title: "習得済み",
                value: "\(store.masteredCount)",
                icon: "checkmark.seal.fill",
                color: AppColors.mastered
            )
            StatCardView(
                title: "学習中",
                value: "\(store.learningCount)",
                icon: "flame.fill",
                color: AppColors.learning
            )
        }
    }

    private var weeklyChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("過去7日間の復習数")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            SimpleBarChart(data: store.reviewCountsLast7Days())
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 12))
    }

    private var deckProgress: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("デッキ別進捗")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            if store.deckProgressList.isEmpty {
                Text("デッキがありません")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                ForEach(store.deckProgressList) { dp in
                    DeckProgressBar(
                        deckName: dp.name,
                        newCount: dp.newCount,
                        learningCount: dp.learningCount,
                        masteredCount: dp.masteredCount
                    )
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 12))
    }

    private var averageEFSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("平均 Ease Factor")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            if let avg = store.averageEF {
                Text(String(format: "%.2f", avg))
                    .font(.title.weight(.bold))
                    .foregroundStyle(AppColors.accent)
            } else {
                Text("-")
                    .font(.title.weight(.bold))
                    .foregroundStyle(.tertiary)
            }

            Text("EFが高いほど記憶が定着しています")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 12))
    }
}
