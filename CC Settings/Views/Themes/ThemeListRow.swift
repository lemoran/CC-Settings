import SwiftUI

/// One row in the Themes sidebar list. Shows the filename plus a swatch strip
/// summarizing the theme's key colors, with an "Active" badge when this theme
/// is the one stored in `settings.json:theme`.
struct ThemeListRow: View {
    let theme: ThemeFile
    let isActive: Bool

    var body: some View {
        HStack(spacing: 10) {
            swatchStrip

            VStack(alignment: .leading, spacing: 2) {
                Text(theme.colors.name ?? theme.id)
                    .font(.body)
                    .lineLimit(1)
                if theme.colors.name != nil && theme.colors.name != theme.id {
                    Text(theme.id)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            if isActive {
                Text("Active")
                    .font(.caption2.bold())
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.accentColor.opacity(0.15))
                    .foregroundColor(.accentColor)
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 2)
    }

    @ViewBuilder
    private var swatchStrip: some View {
        let swatchPaths: [WritableKeyPath<ThemeColors, String?>] = [
            \.background, \.foreground, \.accent, \.error, \.success, \.keyword,
        ]
        HStack(spacing: 2) {
            ForEach(0..<swatchPaths.count, id: \.self) { i in
                swatch(for: swatchPaths[i])
            }
        }
        .padding(2)
        .background(Color.secondary.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }

    @ViewBuilder
    private func swatch(for path: WritableKeyPath<ThemeColors, String?>) -> some View {
        let color: Color = {
            guard let hex = theme.colors[keyPath: path], Color.isValidHex(hex) else {
                return Color.gray.opacity(0.25)
            }
            return Color(hex: hex)
        }()
        RoundedRectangle(cornerRadius: 2)
            .fill(color)
            .frame(width: 12, height: 18)
    }
}
