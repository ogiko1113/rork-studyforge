import Foundation
import OSLog

nonisolated enum StorageKeys {
    static let cards = "studyforge_cards"
    static let reviewLogs = "studyforge_review_logs"
}

@MainActor
enum StorageService {
    private static let defaults = UserDefaults.standard
    private static let decoder = JSONDecoder()
    private static let encoder = JSONEncoder()
    private static let logger = Logger(subsystem: "StudyForge", category: "Storage")

    static func loadCards() -> [Card] {
        guard let data = defaults.data(forKey: StorageKeys.cards) else { return [] }

        do {
            return try decoder.decode([Card].self, from: data)
        } catch {
            logger.error("Failed to decode cards: \(error.localizedDescription, privacy: .public)")
            return []
        }
    }

    static func saveCards(_ cards: [Card]) -> Bool {
        do {
            let data = try encoder.encode(cards)
            defaults.set(data, forKey: StorageKeys.cards)
            return true
        } catch {
            logger.error("Failed to encode cards: \(error.localizedDescription, privacy: .public)")
            return false
        }
    }

    static func loadReviewLogs() -> [ReviewLog] {
        guard let data = defaults.data(forKey: StorageKeys.reviewLogs) else { return [] }

        do {
            return try decoder.decode([ReviewLog].self, from: data)
        } catch {
            logger.error("Failed to decode review logs: \(error.localizedDescription, privacy: .public)")
            return []
        }
    }

    static func saveReviewLogs(_ logs: [ReviewLog]) -> Bool {
        do {
            let data = try encoder.encode(logs)
            defaults.set(data, forKey: StorageKeys.reviewLogs)
            return true
        } catch {
            logger.error("Failed to encode review logs: \(error.localizedDescription, privacy: .public)")
            return false
        }
    }
}
