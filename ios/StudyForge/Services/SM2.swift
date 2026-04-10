import Foundation

nonisolated struct SM2Result: Sendable {
    let ef: Double
    let interval: Double
    let repetitions: Int
    let nextReview: Double
}

nonisolated enum SM2 {
    static func calculate(card: Card, grade: Int, now: Double = Date().timeIntervalSince1970 * 1000) -> SM2Result {
        var ef = card.ef
        var interval = card.interval
        var repetitions = card.repetitions

        let newEF = max(1.3, ef + 0.1 - Double(5 - grade) * (0.08 + Double(5 - grade) * 0.02))
        ef = newEF

        if grade >= 3 {
            if repetitions == 0 {
                interval = 1
            } else if repetitions == 1 {
                interval = 6
            } else {
                interval = (interval * ef).rounded()
            }
            repetitions += 1
        } else {
            repetitions = 0
            interval = 1
        }

        let nextReview = now + interval * 86_400_000

        return SM2Result(ef: ef, interval: interval, repetitions: repetitions, nextReview: nextReview)
    }

    static func simulateInterval(card: Card, grade: Int) -> Double {
        let result = calculate(card: card, grade: grade)
        return result.interval
    }
}
