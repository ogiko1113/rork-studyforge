import Foundation

nonisolated enum StorageKeys {
    static let cards = "studyforge_cards"
    static let reviewLogs = "studyforge_review_logs"
}

@MainActor
enum StorageService {
    private static let defaults = UserDefaults.standard
    private static let decoder = JSONDecoder()
    private static let encoder = JSONEncoder()

    static func loadCards() -> [Card] {
        guard let data = defaults.data(forKey: StorageKeys.cards) else { return [] }
        return (try? decoder.decode([Card].self, from: data)) ?? []
    }

    static func saveCards(_ cards: [Card]) {
        guard let data = try? encoder.encode(cards) else { return }
        defaults.set(data, forKey: StorageKeys.cards)
    }

    static func loadReviewLogs() -> [ReviewLog] {
        guard let data = defaults.data(forKey: StorageKeys.reviewLogs) else { return [] }
        return (try? decoder.decode([ReviewLog].self, from: data)) ?? []
    }

    static func saveReviewLogs(_ logs: [ReviewLog]) {
        guard let data = try? encoder.encode(logs) else { return }
        defaults.set(data, forKey: StorageKeys.reviewLogs)
    }
}
