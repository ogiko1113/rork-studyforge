import SwiftUI
import UIKit

struct ReviewView: View {
    @Environment(StudyDataStore.self) private var store
    @Binding var selectedTab: Int
    @State private var selectedDeck: String? = nil
    @State private var sessionCards: [Card] = []
    @State private var currentIndex: Int = 0
    @State private var isFlipped = false
    @State private var sessionGrades: [Int] = []
    @State private var sessionStartTime: Date = Date()
    @State private var sessionEndTime: Date?
    @State private var sessionFinished = false
    @State private var sessionStarted = false
    @State private var currentFrontImage: UIImage?
    @State private var currentBackImage: UIImage?

    private var totalDue: Int {
        sessionCards.count
    }

    private var currentCard: Card? {
        guard currentIndex < sessionCards.count else { return nil }
        return sessionCards[currentIndex]
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                deckSelector
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                if sessionFinished {
                    completionView
                } else if let card = currentCard, sessionStarted {
                    cardReviewView(card: card)
                } else {
                    emptyReviewState
                }
            }
            .frame(maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("復習")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { startSession() }
            .onChange(of: selectedDeck) { _, _ in startSession() }
        }
    }

    private var deckSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                deckChip(name: "全デッキ", deck: nil, due: store.dueCount())

                ForEach(store.deckNames, id: \.self) { deck in
                    deckChip(name: deck, deck: deck, due: store.dueCount(for: deck))
                }
            }
        }
        .contentMargins(.horizontal, 0)
    }

    private func deckChip(name: String, deck: String?, due: Int) -> some View {
        Button {
            selectedDeck = deck
        } label: {
            HStack(spacing: 4) {
                Text(name)
                    .font(.caption.weight(.medium))
                if due > 0 {
                    Text("\(due)")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(AppColors.accent)
                        .clipShape(.capsule)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(selectedDeck == deck ? AppColors.accent.opacity(0.15) : Color(.tertiarySystemGroupedBackground))
            .foregroundStyle(selectedDeck == deck ? AppColors.accent : .secondary)
            .clipShape(.capsule)
        }
    }

    private func cardReviewView(card: Card) -> some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                Text("\(currentIndex + 1) / \(totalDue)")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.top, 16)

            Button {
                withAnimation {
                    isFlipped = true
                }
            } label: {
                FlashcardFlipView(
                    frontText: card.front,
                    backText: card.back,
                    frontImage: currentFrontImage,
                    backImage: currentBackImage,
                    isFlipped: $isFlipped
                )
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 16)
            .sensoryFeedback(.impact(flexibility: .soft), trigger: isFlipped)

            if isFlipped {
                gradeButtons(card: card)
                    .padding(.horizontal, 16)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            Spacer()
        }
        .animation(.spring(response: 0.3), value: isFlipped)
    }

    private func gradeButtons(card: Card) -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                ReviewGradeButton(
                    label: "もう一度",
                    subtitle: DateHelper.formatRelativeDay(SM2.simulateInterval(card: card, grade: 1)),
                    color: AppColors.gradeAgain
                ) { gradeCard(grade: 1) }

                ReviewGradeButton(
                    label: "うろ覚え",
                    subtitle: DateHelper.formatRelativeDay(SM2.simulateInterval(card: card, grade: 3)),
                    color: AppColors.gradeHard
                ) { gradeCard(grade: 3) }

                ReviewGradeButton(
                    label: "覚えた",
                    subtitle: DateHelper.formatRelativeDay(SM2.simulateInterval(card: card, grade: 4)),
                    color: AppColors.gradeGood
                ) { gradeCard(grade: 4) }

                ReviewGradeButton(
                    label: "完璧",
                    subtitle: DateHelper.formatRelativeDay(SM2.simulateInterval(card: card, grade: 5)),
                    color: AppColors.gradeEasy
                ) { gradeCard(grade: 5) }
            }
        }
    }

    private func gradeCard(grade: Int) {
        guard let card = currentCard else { return }
        store.reviewCard(card, grade: grade)
        sessionGrades.append(grade)

        isFlipped = false

        if currentIndex + 1 >= totalDue {
            sessionEndTime = Date()
            withAnimation { sessionFinished = true }
        } else {
            currentIndex += 1
            loadCurrentImages()
        }
    }

    private func loadCurrentImages() {
        guard let card = currentCard else {
            currentFrontImage = nil
            currentBackImage = nil
            return
        }
        currentFrontImage = card.imageFront.flatMap { ImageStorageService.loadImage(filename: $0) }
        currentBackImage = card.imageBack.flatMap { ImageStorageService.loadImage(filename: $0) }
    }

    private var completionView: some View {
        let totalReviewed = sessionGrades.count
        let successCount = sessionGrades.filter { $0 >= 3 }.count
        let successRate = totalReviewed > 0 ? Int((Double(successCount) / Double(totalReviewed) * 100).rounded()) : 0
        let avgScore = totalReviewed > 0 ? Double(sessionGrades.reduce(0, +)) / Double(totalReviewed) : 0
        let elapsed = (sessionEndTime ?? Date()).timeIntervalSince(sessionStartTime)
        let elapsedSeconds = max(0, Int(elapsed))
        let timeStr = String(format: "%02d:%02d", elapsedSeconds / 60, elapsedSeconds % 60)

        return ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(AppColors.accent)
                        .symbolEffect(.bounce, value: sessionFinished)

                    Text("セッション完了！")
                        .font(.title2.weight(.bold))

                    Text(encouragementMessage(rate: successRate))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 24)

                Grid(horizontalSpacing: 12, verticalSpacing: 12) {
                    GridRow {
                        summaryCard(value: "\(totalReviewed)", unit: "枚", label: "復習枚数")
                        summaryCard(value: "\(successRate)", unit: "%", label: "正答率")
                    }
                    GridRow {
                        summaryCard(value: String(format: "%.1f", avgScore), unit: "", label: "平均スコア")
                        summaryCard(value: timeStr, unit: "", label: "学習時間")
                    }
                }
                .padding(.horizontal, 16)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Grade分布")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 4)

                    gradeDistributionView
                }
                .padding(.horizontal, 16)

                Button {
                    selectedTab = 0
                } label: {
                    Text("ホームに戻る")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 14)
                        .background(AppColors.accent.gradient)
                        .clipShape(.capsule)
                }
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
    }

    private func encouragementMessage(rate: Int) -> String {
        switch rate {
        case 100: return "パーフェクト！🎉"
        case 80...: return "素晴らしい！💪"
        case 60...: return "いい調子です！👍"
        default: return "継続は力なり！📚"
        }
    }

    private func summaryCard(value: String, unit: String, label: String) -> some View {
        VStack(spacing: 6) {
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.title.weight(.bold))
                    .foregroundStyle(AppColors.accent)
                    .monospacedDigit()
                if !unit.isEmpty {
                    Text(unit)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                }
            }
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 12))
    }

    private var gradeDistributionView: some View {
        let counts = Dictionary(grouping: sessionGrades, by: { $0 }).mapValues(\.count)
        let maxCount = counts.values.max() ?? 0

        return VStack(spacing: 10) {
            gradeBar(count: counts[1] ?? 0, max: maxCount, label: "もう一度", color: AppColors.gradeAgain)
            gradeBar(count: counts[3] ?? 0, max: maxCount, label: "うろ覚え", color: AppColors.gradeHard)
            gradeBar(count: counts[4] ?? 0, max: maxCount, label: "覚えた", color: AppColors.gradeGood)
            gradeBar(count: counts[5] ?? 0, max: maxCount, label: "完璧", color: AppColors.gradeEasy)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 12))
    }

    private func gradeBar(count: Int, max: Int, label: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Text(label)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
                .frame(width: 60, alignment: .leading)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.tertiarySystemGroupedBackground))
                        .frame(height: 14)

                    if max > 0 && count > 0 {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(color)
                            .frame(width: geo.size.width * CGFloat(count) / CGFloat(max), height: 14)
                    }
                }
            }
            .frame(height: 14)

            Text("\(count)")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.primary)
                .frame(width: 24, alignment: .trailing)
                .monospacedDigit()
        }
    }

    private var emptyReviewState: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("復習するカードがありません")
                .font(.title3.weight(.semibold))

            if let nextDate = store.nextReviewDate(for: selectedDeck) {
                Text("次回予定: \(DateHelper.formatDateTime(nextDate))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else if store.cards.isEmpty {
                Text("まずカードを追加しましょう")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                Text("次回予定なし")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }

    private func startSession() {
        sessionCards = store.dueCards(for: selectedDeck)
        currentIndex = 0
        isFlipped = false
        sessionGrades = []
        sessionStartTime = Date()
        sessionEndTime = nil
        sessionFinished = false
        sessionStarted = true
        loadCurrentImages()
    }
}
