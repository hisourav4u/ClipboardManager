import Foundation
import AppKit

struct ClipboardEntry: Identifiable, Codable {
    var id: UUID
    var textContent: String?
    var hasImage: Bool          // actual image bytes live in a sidecar file
    var contentType: String
    var timestamp: Date
    var isPinned: Bool
    var sourceApp: String?

    init(
        id: UUID = UUID(),
        textContent: String? = nil,
        hasImage: Bool = false,
        contentType: String,
        timestamp: Date = Date(),
        isPinned: Bool = false,
        sourceApp: String? = nil
    ) {
        self.id = id
        self.textContent = textContent
        self.hasImage = hasImage
        self.contentType = contentType
        self.timestamp = timestamp
        self.isPinned = isPinned
        self.sourceApp = sourceApp
    }

    var displayText: String {
        textContent?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }

    var isImage: Bool { hasImage }

    var isURL: Bool {
        guard let text = textContent else { return false }
        return text.hasPrefix("http://") || text.hasPrefix("https://") || text.hasPrefix("ftp://")
    }

    var isCode: Bool {
        guard let text = textContent, !isURL else { return false }
        let patterns = ["func ", "class ", "struct ", "import ", "let ", "var ", "const ", "def ",
                        "function ", "public ", "private ", "{", "};", "=>", "->", "#include"]
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return patterns.contains { t.contains($0) } && t.contains("\n")
    }

    var typeIcon: String {
        if isImage { return "photo" }
        if isURL { return "link" }
        if isCode { return "curlybraces" }
        if contentType == "public.rtf" { return "textformat" }
        return "doc.text"
    }
}
