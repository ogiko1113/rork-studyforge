import SwiftUI

@Observable
@MainActor
class StudyDataStore {
    var cards: [Card] = []
    var reviewLogs: [ReviewLog] = []

    init() {
        cards = StorageService.loadCards()
        reviewLogs = StorageService.loadReviewLogs()
    }

    var deckNames: [String] {
        Array(Set(cards.map(\.deck))).sorted()
    }

    func cardsForDeck(_ deck: String) -> [Card] {
        cards.filter { $0.deck == deck }
    }

    func dueCount(for deck: String? = nil) -> Int {
        let now = DateHelper.nowMillis()
        let filtered = deck.map { d in cards.filter { $0.deck == d } } ?? cards
        return filtered.filter { $0.nextReview <= now }.count
    }

    func dueCards(for deck: String? = nil) -> [Card] {
        let now = DateHelper.nowMillis()
        let filtered = deck.map { d in cards.filter { $0.deck == d } } ?? cards
        return filtered.filter { $0.nextReview <= now }.shuffled()
    }

    func nextReviewDate(for deck: String? = nil) -> Double? {
        let now = DateHelper.nowMillis()
        let filtered = deck.map { d in cards.filter { $0.deck == d } } ?? cards
        let future = filtered.filter { $0.nextReview > now }
        return future.map(\.nextReview).min()
    }

    struct DeckInfo: Identifiable {
        let name: String
        let cardCount: Int
        let dueCount: Int
        var id: String { name }
    }

    var sortedDecks: [DeckInfo] {
        let now = DateHelper.nowMillis()
        let grouped = Dictionary(grouping: cards, by: \.deck)
        return grouped.map { deck, deckCards in
            let due = deckCards.filter { $0.nextReview <= now }.count
            return DeckInfo(name: deck, cardCount: deckCards.count, dueCount: due)
        }
        .sorted { a, b in
            if a.dueCount != b.dueCount { return a.dueCount > b.dueCount }
            if a.cardCount != b.cardCount { return a.cardCount > b.cardCount }
            return a.name < b.name
        }
    }

    func addCard(front: String, back: String, deck: String) {
        let card = Card(front: front, back: back, deck: deck)
        cards.append(card)
        saveCards()
    }

    func addCards(_ newCards: [(front: String, back: String)], deck: String) {
        for c in newCards {
            let card = Card(front: c.front, back: c.back, deck: deck)
            cards.append(card)
        }
        saveCards()
    }

    func updateCard(_ card: Card, front: String, back: String, deck: String) {
        guard let index = cards.firstIndex(where: { $0.id == card.id }) else { return }
        cards[index].front = front
        cards[index].back = back
        cards[index].deck = deck
        saveCards()
    }

    func deleteCard(_ card: Card) {
        cards.removeAll { $0.id == card.id }
        reviewLogs.removeAll { $0.cardId == card.id }
        saveCards()
        saveLogs()
    }

    func deleteDeck(_ deckName: String) {
        let cardIds = Set(cards.filter { $0.deck == deckName }.map(\.id))
        cards.removeAll { $0.deck == deckName }
        reviewLogs.removeAll { cardIds.contains($0.cardId) }
        saveCards()
        saveLogs()
    }

    func reviewCard(_ card: Card, grade: Int) {
        let now = DateHelper.nowMillis()
        let result = SM2.calculate(card: card, grade: grade, now: now)

        guard let index = cards.firstIndex(where: { $0.id == card.id }) else { return }
        cards[index].ef = result.ef
        cards[index].interval = result.interval
        cards[index].repetitions = result.repetitions
        cards[index].nextReview = result.nextReview
        cards[index].lastReview = now
        cards[index].grade = grade

        let log = ReviewLog(
            cardId: card.id,
            deck: card.deck,
            grade: grade,
            reviewedAt: now,
            success: grade >= 3
        )
        reviewLogs.append(log)

        saveCards()
        saveLogs()
    }

    var totalCards: Int { cards.count }

    var todayReviewCount: Int {
        let todayStart = DateHelper.startOfDayMillis()
        let tomorrowStart = todayStart + 86_400_000
        return reviewLogs.filter { $0.reviewedAt >= todayStart && $0.reviewedAt < tomorrowStart }.count
    }

    var masteredCount: Int {
        cards.filter { $0.repetitions >= 5 }.count
    }

    var learningCount: Int {
        cards.filter { $0.repetitions > 0 && $0.repetitions < 5 }.count
    }

    var averageEF: Double? {
        guard !cards.isEmpty else { return nil }
        return cards.map(\.ef).reduce(0, +) / Double(cards.count)
    }

    func reviewCountsLast7Days() -> [BarData] {
        var result: [BarData] = []
        for i in stride(from: 6, through: 0, by: -1) {
            let day = DateHelper.daysAgo(i)
            let dayStart = DateHelper.startOfDayMillis(for: day)
            let dayEnd = dayStart + 86_400_000
            let count = reviewLogs.filter { $0.reviewedAt >= dayStart && $0.reviewedAt < dayEnd }.count
            result.append(BarData(label: DateHelper.formatShortDate(day), value: count))
        }
        return result
    }

    struct DeckProgress: Identifiable {
        let name: String
        let newCount: Int
        let learningCount: Int
        let masteredCount: Int
        var id: String { name }
    }

    var deckProgressList: [DeckProgress] {
        let grouped = Dictionary(grouping: cards, by: \.deck)
        return grouped.map { deck, deckCards in
            DeckProgress(
                name: deck,
                newCount: deckCards.filter { $0.repetitions == 0 }.count,
                learningCount: deckCards.filter { $0.repetitions > 0 && $0.repetitions < 5 }.count,
                masteredCount: deckCards.filter { $0.repetitions >= 5 }.count
            )
        }
        .sorted { $0.name < $1.name }
    }

    private func saveCards() {
        StorageService.saveCards(cards)
    }

    private func saveLogs() {
        StorageService.saveReviewLogs(reviewLogs)
    }
}
