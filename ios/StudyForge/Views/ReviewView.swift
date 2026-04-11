import SwiftUI
import UIKit

struct ReviewView: View {
    @Environment(StudyDataStore.self) private var store
    @State private var selectedDeck: String? = nil
    @State private var sessionCards: [Card] = []
    @State private var currentIndex: Int = 0
    @State private var isFlipped = false
    @State private var reviewedCount: Int = 0
    @State private var successCount: Int = 0
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
        reviewedCount += 1
        if grade >= 3 { successCount += 1 }

        isFlipped = false

        if currentIndex + 1 >= totalDue {
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
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(AppColors.accent)
                .symbolEffect(.bounce, value: sessionFinished)

            Text("お疲れ様！")
                .font(.title.weight(.bold))

            VStack(spacing: 8) {
                Text("復習枚数: \(reviewedCount)枚")
                    .font(.headline)

                if reviewedCount > 0 {
                    let rate = Int(Double(successCount) / Double(reviewedCount) * 100)
                    Text("正答率: \(rate)%")
                        .font(.headline)
                        .foregroundStyle(rate >= 80 ? AppColors.mastered : rate >= 50 ? AppColors.learning : AppColors.gradeAgain)
                }
            }

            Button {
                startSession()
            } label: {
                Text("もう一度")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(AppColors.accent.gradient)
                    .clipShape(.capsule)
            }
            .padding(.top, 8)

            Spacer()
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
        reviewedCount = 0
        successCount = 0
        sessionFinished = false
        sessionStarted = true
        loadCurrentImages()
    }
}
