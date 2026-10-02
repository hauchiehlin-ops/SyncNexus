import Foundation
import SwiftUI

public enum AppLanguage: String, CaseIterable, Identifiable {
    case en = "en"
    case zhHant = "zh-Hant"
    case zhHans = "zh-Hans"
    case ja = "ja"
    case th = "th"
    case ko = "ko"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .en: return "English"
        case .zhHant: return "繁體中文"
        case .zhHans: return "简体中文"
        case .ja: return "日本語"
        case .th: return "ไทย"
        case .ko: return "한국어"
        }
    }
}

public final class L10n: ObservableObject {
    public static let shared = L10n()

    @Published public var currentLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "app_language")
        }
    }

    private init() {
        if let saved = UserDefaults.standard.string(forKey: "app_language"),
           let lang = AppLanguage(rawValue: saved) {
            self.currentLanguage = lang
        } else {
            // Auto detect from system preferred languages
            let preferred = Locale.preferredLanguages.first ?? "en"
            if preferred.hasPrefix("zh-Hant") || preferred.hasPrefix("zh-TW") || preferred.hasPrefix("zh-HK") {
                self.currentLanguage = .zhHant
            } else if preferred.hasPrefix("zh-Hans") || preferred.hasPrefix("zh-CN") {
                self.currentLanguage = .zhHans
            } else if preferred.hasPrefix("ja") {
                self.currentLanguage = .ja
            } else if preferred.hasPrefix("th") {
                self.currentLanguage = .th
            } else if preferred.hasPrefix("ko") {
                self.currentLanguage = .ko
            } else {
                self.currentLanguage = .en
            }
        }
    }

    public static func tr(_ key: String, _ args: CVarArg...) -> String {
        let lang = shared.currentLanguage
        let template = StringsTable[key]?[lang] ?? StringsTable[key]?[.en] ?? key
        if args.isEmpty {
            return template
        }
        return String(format: template, arguments: args)
    }
}

// Global helper function for UI
public func loc(_ key: String, _ args: CVarArg...) -> String {
    let lang = L10n.shared.currentLanguage
    let template = StringsTable[key]?[lang] ?? StringsTable[key]?[.en] ?? key
    if args.isEmpty {
        return template
    }
    return String(format: template, arguments: args)
}
