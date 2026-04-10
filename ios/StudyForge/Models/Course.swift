import Foundation

nonisolated struct Course: Codable, Identifiable, Sendable, Hashable {
    let id: String
    var name: String
    var deckNames: [String]
    var created: Double

    init(
        id: String = UUID().uuidString,
        name: String,
        deckNames: [String] = [],
        created: Double? = nil
    ) {
        self.id = id
        self.name = name
        self.deckNames = deckNames
        self.created = created ?? Date().timeIntervalSince1970 * 1000
    }
}
