import SwiftUI

struct AppearanceView: View {
    @AppStorage("appearance") private var appearanceRaw: String = AppearanceOption.system.rawValue

    var body: some View {
        List {
            Section {
                Picker("Appearance", selection: $appearanceRaw) {
                    ForEach(AppearanceOption.allCases) { option in
                        Text(option.title).tag(option.rawValue)
                    }
                }
                .pickerStyle(.inline)
            } footer: {
                Text("System follows your device settings.")
            }
        }
        .navigationTitle("Appearance")
    }
}

enum AppearanceOption: String, CaseIterable, Identifiable {
    case system, light, dark
    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    static var currentTitle: String {
        let raw = UserDefaults.standard.string(forKey: "appearance") ?? AppearanceOption.system.rawValue
        return AppearanceOption(rawValue: raw)?.title ?? "System"
    }
}
