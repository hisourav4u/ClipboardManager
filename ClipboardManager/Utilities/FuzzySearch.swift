import Foundation

enum FuzzySearch {
    static func matches(query: String, in text: String) -> Bool {
        guard !query.isEmpty else { return true }

        let q = query.lowercased()
        let t = text.lowercased()

        if t.contains(q) { return true }

        // Fuzzy: all query chars appear in text in order
        var qi = q.startIndex
        for ch in t {
            if qi == q.endIndex { break }
            if ch == q[qi] { qi = q.index(after: qi) }
        }
        return qi == q.endIndex
    }

    static func score(query: String, in text: String) -> Double {
        guard !query.isEmpty, !text.isEmpty else { return 0 }

        let q = query.lowercased()
        let t = text.lowercased()

        if t == q { return 1.0 }
        if t.hasPrefix(q) { return 0.9 }
        if t.contains(q) { return 0.8 }
        if matches(query: q, in: t) { return 0.5 }

        return 0
    }
}
