import Foundation

nonisolated struct Card: Codable, Identifiable, Sendable, Hashable {
    let id: String
    var front: String
    var back: String
    var deck: String
    var ef: Double
    var interval: Double
    var repetitions: Int
    var nextReview: Double
    var lastReview: Double
    var grade: Int
    var created: Double

    init(
        id: String = UUID().uuidString,
        front: String,
        back: String,
        deck: String,
        ef: Double = 2.5,
        interval: Double = 0,
        repetitions: Int = 0,
        nextReview: Double? = nil,
        lastReview: Double = 0,
        grade: Int = 0,
        created: Double? = nil
    ) {
        self.id = id
        self.front = front
        self.back = back
        self.deck = deck
        self.ef = ef
        self.interval = interval
        self.repetitions = repetitions
        let now = created ?? Date().timeIntervalSince1970 * 1000
        self.nextReview = nextReview ?? now
        self.lastReview = lastReview
        self.grade = grade
        self.created = now
    }
}
