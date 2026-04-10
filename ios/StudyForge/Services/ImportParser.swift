import Foundation

nonisolated struct ParsedCard: Sendable {
    let front: String
    let back: String
}

nonisolated enum ImportParser {
    static func parse(_ text: String) -> [ParsedCard] {
        let lines = text.components(separatedBy: .newlines)
        var results: [ParsedCard] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty { continue }

            if trimmed.contains("\t") {
                let parts = trimmed.components(separatedBy: "\t")
                if parts.count >= 2 {
                    let front = parts[0].trimmingCharacters(in: .whitespaces)
                    let back = parts[1].trimmingCharacters(in: .whitespaces)
                    if !front.isEmpty && !back.isEmpty {
                        results.append(ParsedCard(front: front, back: back))
                    }
                }
            } else if trimmed.contains(",") {
                let parts = parseCSVLine(trimmed)
                if parts.count >= 2 {
                    let front = parts[0].trimmingCharacters(in: .whitespaces)
                    let back = parts[1].trimmingCharacters(in: .whitespaces)
                    if !front.isEmpty && !back.isEmpty {
                        results.append(ParsedCard(front: front, back: back))
                    }
                }
            }
        }

        return results
    }

    private static func parseCSVLine(_ line: String) -> [String] {
        var fields: [String] = []
        var current = ""
        var inQuotes = false

        for char in line {
            if char == "\"" {
                inQuotes.toggle()
            } else if char == "," && !inQuotes {
                fields.append(current)
                current = ""
            } else {
                current.append(char)
            }
        }
        fields.append(current)

        return fields
    }
}
