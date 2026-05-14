import Foundation

// MARK: - ThemeFile

/// A single Claude Code theme file stored at `~/.claude/themes/<id>.json`.
/// Known fields are surfaced via `colors`; everything else is preserved in
/// `unknownFields` so structured edits never silently drop schema-novel keys.
struct ThemeFile: Identifiable {
    let id: String        // filename stem, e.g. "midnight"
    let url: URL          // ~/.claude/themes/midnight.json
    var colors: ThemeColors
    var unknownFields: [String: Any]

    static func load(from url: URL) -> ThemeFile? {
        guard let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { return nil }

        let id = url.deletingPathExtension().lastPathComponent
        var colors = ThemeColors()
        var unknown: [String: Any] = [:]

        for (key, value) in json {
            if ThemeColors.knownKeys.contains(key), let stringValue = value as? String {
                colors.setValue(stringValue, forKey: key)
            } else {
                unknown[key] = value
            }
        }

        return ThemeFile(id: id, url: url, colors: colors, unknownFields: unknown)
    }

    /// Serializes the theme back to JSON, merging known + unknown fields with sorted keys.
    func serialize() throws -> Data {
        var merged: [String: Any] = unknownFields
        for (key, value) in colors.asDictionary() {
            merged[key] = value
        }
        return try JSONSerialization.data(withJSONObject: merged, options: [.prettyPrinted, .sortedKeys])
    }
}

extension ThemeFile: Equatable {
    static func == (lhs: ThemeFile, rhs: ThemeFile) -> Bool {
        guard lhs.id == rhs.id, lhs.url == rhs.url, lhs.colors == rhs.colors else { return false }
        let lhsData = try? JSONSerialization.data(withJSONObject: lhs.unknownFields, options: [.sortedKeys])
        let rhsData = try? JSONSerialization.data(withJSONObject: rhs.unknownFields, options: [.sortedKeys])
        return lhsData == rhsData
    }
}

// MARK: - ThemeColors

/// Best-effort set of color-typed fields a Claude Code theme is likely to contain.
/// Schema isn't publicly documented — fields not listed here are preserved in
/// `ThemeFile.unknownFields` so we never lose data on round-trip.
struct ThemeColors: Equatable {
    // Identity
    var name: String?
    var description: String?

    // UI surfaces
    var background: String?
    var foreground: String?
    var cursor: String?
    var selection: String?

    // Brand
    var accent: String?
    var primary: String?

    // Status
    var error: String?
    var warning: String?
    var success: String?
    var info: String?

    // Text variations
    var muted: String?
    var secondary: String?

    // Syntax highlighting
    var keyword: String?
    var string: String?
    var comment: String?
    var number: String?
    var function: String?
    var type: String?

    // ANSI 16-color palette
    var ansiBlack: String?
    var ansiRed: String?
    var ansiGreen: String?
    var ansiYellow: String?
    var ansiBlue: String?
    var ansiMagenta: String?
    var ansiCyan: String?
    var ansiWhite: String?
    var ansiBrightBlack: String?
    var ansiBrightRed: String?
    var ansiBrightGreen: String?
    var ansiBrightYellow: String?
    var ansiBrightBlue: String?
    var ansiBrightMagenta: String?
    var ansiBrightCyan: String?
    var ansiBrightWhite: String?

    static let knownKeys: Set<String> = [
        "name", "description",
        "background", "foreground", "cursor", "selection",
        "accent", "primary",
        "error", "warning", "success", "info",
        "muted", "secondary",
        "keyword", "string", "comment", "number", "function", "type",
        "ansiBlack", "ansiRed", "ansiGreen", "ansiYellow",
        "ansiBlue", "ansiMagenta", "ansiCyan", "ansiWhite",
        "ansiBrightBlack", "ansiBrightRed", "ansiBrightGreen", "ansiBrightYellow",
        "ansiBrightBlue", "ansiBrightMagenta", "ansiBrightCyan", "ansiBrightWhite",
    ]

    mutating func setValue(_ value: String, forKey key: String) {
        switch key {
        case "name": name = value
        case "description": description = value
        case "background": background = value
        case "foreground": foreground = value
        case "cursor": cursor = value
        case "selection": selection = value
        case "accent": accent = value
        case "primary": primary = value
        case "error": error = value
        case "warning": warning = value
        case "success": success = value
        case "info": info = value
        case "muted": muted = value
        case "secondary": secondary = value
        case "keyword": keyword = value
        case "string": string = value
        case "comment": comment = value
        case "number": number = value
        case "function": function = value
        case "type": type = value
        case "ansiBlack": ansiBlack = value
        case "ansiRed": ansiRed = value
        case "ansiGreen": ansiGreen = value
        case "ansiYellow": ansiYellow = value
        case "ansiBlue": ansiBlue = value
        case "ansiMagenta": ansiMagenta = value
        case "ansiCyan": ansiCyan = value
        case "ansiWhite": ansiWhite = value
        case "ansiBrightBlack": ansiBrightBlack = value
        case "ansiBrightRed": ansiBrightRed = value
        case "ansiBrightGreen": ansiBrightGreen = value
        case "ansiBrightYellow": ansiBrightYellow = value
        case "ansiBrightBlue": ansiBrightBlue = value
        case "ansiBrightMagenta": ansiBrightMagenta = value
        case "ansiBrightCyan": ansiBrightCyan = value
        case "ansiBrightWhite": ansiBrightWhite = value
        default: break
        }
    }

    /// Emits a dict of the non-nil fields. Used during serialization.
    func asDictionary() -> [String: String] {
        var dict: [String: String] = [:]
        if let v = name { dict["name"] = v }
        if let v = description { dict["description"] = v }
        if let v = background { dict["background"] = v }
        if let v = foreground { dict["foreground"] = v }
        if let v = cursor { dict["cursor"] = v }
        if let v = selection { dict["selection"] = v }
        if let v = accent { dict["accent"] = v }
        if let v = primary { dict["primary"] = v }
        if let v = error { dict["error"] = v }
        if let v = warning { dict["warning"] = v }
        if let v = success { dict["success"] = v }
        if let v = info { dict["info"] = v }
        if let v = muted { dict["muted"] = v }
        if let v = secondary { dict["secondary"] = v }
        if let v = keyword { dict["keyword"] = v }
        if let v = string { dict["string"] = v }
        if let v = comment { dict["comment"] = v }
        if let v = number { dict["number"] = v }
        if let v = function { dict["function"] = v }
        if let v = type { dict["type"] = v }
        if let v = ansiBlack { dict["ansiBlack"] = v }
        if let v = ansiRed { dict["ansiRed"] = v }
        if let v = ansiGreen { dict["ansiGreen"] = v }
        if let v = ansiYellow { dict["ansiYellow"] = v }
        if let v = ansiBlue { dict["ansiBlue"] = v }
        if let v = ansiMagenta { dict["ansiMagenta"] = v }
        if let v = ansiCyan { dict["ansiCyan"] = v }
        if let v = ansiWhite { dict["ansiWhite"] = v }
        if let v = ansiBrightBlack { dict["ansiBrightBlack"] = v }
        if let v = ansiBrightRed { dict["ansiBrightRed"] = v }
        if let v = ansiBrightGreen { dict["ansiBrightGreen"] = v }
        if let v = ansiBrightYellow { dict["ansiBrightYellow"] = v }
        if let v = ansiBrightBlue { dict["ansiBrightBlue"] = v }
        if let v = ansiBrightMagenta { dict["ansiBrightMagenta"] = v }
        if let v = ansiBrightCyan { dict["ansiBrightCyan"] = v }
        if let v = ansiBrightWhite { dict["ansiBrightWhite"] = v }
        return dict
    }

    /// Starter values for a new theme — keeps the editor populated rather than blank.
    static let starter = ThemeColors(
        name: "untitled",
        background: "#0a0a0a",
        foreground: "#e0e0e0",
        accent: "#4a90e2"
    )
}
