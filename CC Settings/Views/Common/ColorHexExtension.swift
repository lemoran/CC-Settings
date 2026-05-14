import SwiftUI
import AppKit

extension Color {
    /// Parses a CSS-style hex color string. Accepts `"#rgb"`, `"#rrggbb"`, `"#rrggbbaa"`
    /// (with or without the leading `#`). Falls back to white for malformed input to
    /// keep callers that assume non-failable construction (e.g. HUD color cells) simple.
    init(hex raw: String) {
        var s = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.hasPrefix("#") { s.removeFirst() }
        guard let value = UInt64(s, radix: 16) else {
            self.init(.sRGB, red: 1, green: 1, blue: 1, opacity: 1)
            return
        }
        let r, g, b, a: Double
        switch s.count {
        case 3:
            r = Double((value >> 8) & 0xF) / 15.0
            g = Double((value >> 4) & 0xF) / 15.0
            b = Double(value & 0xF) / 15.0
            a = 1
        case 6:
            r = Double((value >> 16) & 0xFF) / 255.0
            g = Double((value >> 8) & 0xFF) / 255.0
            b = Double(value & 0xFF) / 255.0
            a = 1
        case 8:
            r = Double((value >> 24) & 0xFF) / 255.0
            g = Double((value >> 16) & 0xFF) / 255.0
            b = Double((value >> 8) & 0xFF) / 255.0
            a = Double(value & 0xFF) / 255.0
        default:
            self.init(.sRGB, red: 1, green: 1, blue: 1, opacity: 1)
            return
        }
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }

    /// Returns true if `raw` parses cleanly. Use this for fields where empty / malformed
    /// input should render a placeholder instead of falling back to white.
    static func isValidHex(_ raw: String) -> Bool {
        var s = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.hasPrefix("#") { s.removeFirst() }
        guard UInt64(s, radix: 16) != nil else { return false }
        return [3, 6, 8].contains(s.count)
    }

    /// Returns the sRGB hex representation of this color in `"#RRGGBB"` form.
    /// Drops alpha. Returns nil if the color can't be resolved in sRGB.
    var hexString: String? {
        guard let resolved = NSColor(self).usingColorSpace(.sRGB) else { return nil }
        let r = Int(round(resolved.redComponent * 255).clamped(to: 0...255))
        let g = Int(round(resolved.greenComponent * 255).clamped(to: 0...255))
        let b = Int(round(resolved.blueComponent * 255).clamped(to: 0...255))
        return String(format: "#%02X%02X%02X", r, g, b)
    }

    /// Lowercase hex form, defaults to `"#000000"` if the color can't be resolved.
    /// Kept for the HUD config call site that pre-dated the consolidation.
    func toHex() -> String {
        guard let hex = hexString else { return "#000000" }
        return hex.lowercased()
    }
}

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
