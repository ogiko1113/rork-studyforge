import UIKit

nonisolated enum CardSide {
    case front, back

    var suffix: String {
        switch self {
        case .front: return "front"
        case .back: return "back"
        }
    }
}

nonisolated enum ImageStorageService {
    private static let dirName = "card_images"
    private static let compression: CGFloat = 0.8

    static func directoryURL() -> URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dir = docs.appendingPathComponent(dirName, isDirectory: true)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    static func filename(cardId: String, side: CardSide) -> String {
        "\(cardId)_\(side.suffix).jpg"
    }

    static func url(for filename: String) -> URL {
        directoryURL().appendingPathComponent(filename)
    }

    @discardableResult
    static func saveImage(_ image: UIImage, cardId: String, side: CardSide) -> String? {
        guard let data = image.jpegData(compressionQuality: compression) else { return nil }
        let name = filename(cardId: cardId, side: side)
        let fileURL = url(for: name)
        do {
            try data.write(to: fileURL, options: .atomic)
            return name
        } catch {
            return nil
        }
    }

    static func loadImage(filename: String) -> UIImage? {
        UIImage(contentsOfFile: url(for: filename).path)
    }

    static func deleteImage(filename: String) {
        let fileURL = url(for: filename)
        try? FileManager.default.removeItem(at: fileURL)
    }

    static func deleteImage(cardId: String, side: CardSide) {
        deleteImage(filename: filename(cardId: cardId, side: side))
    }
}
