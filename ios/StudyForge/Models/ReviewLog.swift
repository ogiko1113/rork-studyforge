import Foundation

nonisolated struct ReviewLog: Codable, Identifiable, Sendable {
    let id: String
    let cardId: String
    let deck: String
    let grade: Int
    let reviewedAt: Double
    let success: Bool

    init(
        id: String = UUID().uuidString,
        cardId: String,
        deck: String,
        grade: Int,
        reviewedAt: Double = Date().timeIntervalSince1970 * 1000,
        success: Bool
    ) {
        self.id = id
        self.cardId = cardId
        self.deck = deck
        self.grade = grade
        self.reviewedAt = reviewedAt
        self.success = success
    }
}
