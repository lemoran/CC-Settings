import SwiftUI

/// Structured editor for a `ThemeFile.colors`. Fields the schema doesn't know
/// about live in `ThemeFile.unknownFields` and are surfaced in the disclosure
/// at the bottom (read-only — switch to JSON view to edit them).
struct ThemeColorsEditor: View {
    @Binding var theme: ThemeFile
    let onChange: () -> Void

    var body: some View {
        Form {
            Section("Identity") {
                LabeledContent("Name") {
                    TextField("untitled", text: stringBinding(\.name))
                        .textFieldStyle(.roundedBorder)
                        .font(.system(.body, design: .monospaced))
                }
                LabeledContent("Description") {
                    TextField("optional", text: stringBinding(\.description))
                        .textFieldStyle(.roundedBorder)
                }
            }

            Section("Brand") {
                colorRow("Accent", path: \.accent)
                colorRow("Primary", path: \.primary)
            }

            Section("Status") {
                colorRow("Error", path: \.error)
                colorRow("Warning", path: \.warning)
                colorRow("Success", path: \.success)
                colorRow("Info", path: \.info)
            }

            Section("Text Variations") {
                colorRow("Muted", path: \.muted)
                colorRow("Secondary", path: \.secondary)
            }

            Section("Syntax") {
                colorRow("Keyword", path: \.keyword)
                colorRow("String", path: \.string)
                colorRow("Comment", path: \.comment)
                colorRow("Number", path: \.number)
                colorRow("Function", path: \.function)
                colorRow("Type", path: \.type)
            }

            Section("ANSI Palette") {
                ansiGrid
            }

            if !theme.unknownFields.isEmpty {
                Section {
                    DisclosureGroup("Custom Fields (\(theme.unknownFields.count))") {
                        ForEach(theme.unknownFields.keys.sorted(), id: \.self) { key in
                            HStack {
                                Text(key)
                                    .font(.caption.monospaced())
                                Spacer()
                                Text(stringPreview(of: theme.unknownFields[key]))
                                    .font(.caption.monospaced())
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                            }
                        }

                        Text("Edit in JSON view to modify these fields. They're preserved through every save.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                }
            }
        }
        .formStyle(.grouped)
    }

    // MARK: - ANSI Palette grid

    @ViewBuilder
    private var ansiGrid: some View {
        let rows: [[(String, WritableKeyPath<ThemeColors, String?>)]] = [
            [("Black", \.ansiBlack), ("Red", \.ansiRed), ("Green", \.ansiGreen), ("Yellow", \.ansiYellow)],
            [("Blue", \.ansiBlue), ("Magenta", \.ansiMagenta), ("Cyan", \.ansiCyan), ("White", \.ansiWhite)],
            [("Bright Black", \.ansiBrightBlack), ("Bright Red", \.ansiBrightRed), ("Bright Green", \.ansiBrightGreen), ("Bright Yellow", \.ansiBrightYellow)],
            [("Bright Blue", \.ansiBrightBlue), ("Bright Magenta", \.ansiBrightMagenta), ("Bright Cyan", \.ansiBrightCyan), ("Bright White", \.ansiBrightWhite)],
        ]
        VStack(spacing: 6) {
            ForEach(0..<rows.count, id: \.self) { rowIndex in
                HStack(spacing: 12) {
                    ForEach(0..<rows[rowIndex].count, id: \.self) { colIndex in
                        let cell = rows[rowIndex][colIndex]
                        compactColorCell(label: cell.0, path: cell.1)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private func compactColorCell(label: String, path: WritableKeyPath<ThemeColors, String?>) -> some View {
        VStack(spacing: 4) {
            ColorPicker("", selection: colorBinding(for: path), supportsOpacity: false)
                .labelsHidden()
                .frame(width: 36, height: 28)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Standard color row

    @ViewBuilder
    private func colorRow(_ label: String, path: WritableKeyPath<ThemeColors, String?>) -> some View {
        LabeledContent(label) {
            HStack(spacing: 8) {
                Text(theme.colors[keyPath: path] ?? "—")
                    .font(.caption.monospaced())
                    .foregroundColor(.secondary)
                    .frame(width: 70, alignment: .trailing)
                ColorPicker("", selection: colorBinding(for: path), supportsOpacity: false)
                    .labelsHidden()
            }
        }
    }

    // MARK: - Bindings

    private func colorBinding(for path: WritableKeyPath<ThemeColors, String?>) -> Binding<Color> {
        Binding<Color>(
            get: {
                guard let hex = theme.colors[keyPath: path], Color.isValidHex(hex) else {
                    return Color.gray.opacity(0.25)
                }
                return Color(hex: hex)
            },
            set: { newColor in
                let hex = newColor.hexString ?? "#000000"
                theme.colors[keyPath: path] = hex
                onChange()
            }
        )
    }

    private func stringBinding(_ path: WritableKeyPath<ThemeColors, String?>) -> Binding<String> {
        Binding<String>(
            get: { theme.colors[keyPath: path] ?? "" },
            set: { newValue in
                let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                theme.colors[keyPath: path] = trimmed.isEmpty ? nil : trimmed
                onChange()
            }
        )
    }

    private func stringPreview(of value: Any?) -> String {
        switch value {
        case let s as String: return s
        case let n as NSNumber: return n.stringValue
        case let arr as [Any]: return "[\(arr.count) items]"
        case let dict as [String: Any]: return "{\(dict.count) keys}"
        case nil: return "—"
        default: return String(describing: value ?? "—")
        }
    }
}
