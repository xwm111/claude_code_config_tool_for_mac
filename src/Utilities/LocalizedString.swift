//
//  LocalizedString.swift
//  ClaudeCodeConfig
//
//  Created by weiming on 2025-10-29.
//  Copyright © 2025 weiming. All rights reserved.
//

import SwiftUI

/// Localized string helper for internationalization
extension String {
    /// Get localized string without arguments
    /// - Returns: Localized string
    func localized() -> String {
        let helper = LocalizationHelper.shared
        let localized = NSLocalizedString(self, bundle: helper.bundle, comment: "")
        return localized
    }
    
    /// Get localized string with arguments
    /// - Parameter arguments: Arguments to format into the localized string
    /// - Returns: Localized string
    func localized(arguments: CVarArg...) -> String {
        let helper = LocalizationHelper.shared
        let localized = NSLocalizedString(self, bundle: helper.bundle, comment: "")
        if arguments.isEmpty {
            return localized
        } else {
            return String(format: localized, arguments: arguments)
        }
    }
}

/// Localized text view for SwiftUI
struct LocalizedText: View {
    let key: String
    let arguments: [CVarArg]
    @ObservedObject private var localizationHelper = LocalizationHelper.shared

    init(_ key: String, arguments: CVarArg...) {
        self.key = key
        self.arguments = arguments
    }

    var body: some View {
        Text(localizedString)
    }
    
    private var localizedString: String {
        let localized = NSLocalizedString(key, bundle: localizationHelper.bundle, comment: "")
        if arguments.isEmpty {
            return localized
        } else {
            return String(format: localized, arguments: arguments)
        }
    }
}

/// Localized stringKey for SwiftUI
extension LocalizedStringKey {
    /// Initialize with localization key and arguments
    init(localized key: String, arguments: CVarArg...) {
        let localized = key.localized(arguments: arguments)
        self.init(localized)
    }
}

/// Localization helper class
class LocalizationHelper: ObservableObject {
    static let shared = LocalizationHelper()

    @Published var currentLanguage: String {
        didSet {
            UserDefaults.standard.set(currentLanguage, forKey: "AppLanguage")
            // Force UI update by changing a dummy property
            self.refreshTrigger.toggle()
            NotificationCenter.default.post(name: .languageChanged, object: nil)
        }
    }
    
    @Published var refreshTrigger: Bool = false

    init() {
        // Get language from UserDefaults or use system preferred language
        if let savedLanguage = UserDefaults.standard.string(forKey: "AppLanguage") {
            currentLanguage = savedLanguage
        } else {
            // Get system preferred language
            let preferredLanguages = Locale.preferredLanguages
            if let firstLanguage = preferredLanguages.first {
                currentLanguage = firstLanguage.prefix(2).description // Get language code like "en", "zh"
            } else {
                currentLanguage = "en" // Default to English
            }
        }
    }

    /// Set language and restart needed UI components
    func setLanguage(_ languageCode: String) {
        currentLanguage = languageCode
    }

    /// Get current localized bundle
    var bundle: Bundle {
        // 首先尝试从应用程序包中查找
        if let path = Bundle.main.path(forResource: currentLanguage, ofType: "lproj", inDirectory: "Localizations"),
           let bundle = Bundle(path: path) {
            return bundle
        }
        
        // 如果找不到，尝试直接路径
        let directPath = "\(Bundle.main.bundlePath)/Contents/Resources/Localizations/\(currentLanguage).lproj"
        if let bundle = Bundle(path: directPath) {
            return bundle
        }
        
        // 最后返回主包
        return Bundle.main
    }

    /// Get localized string for key
    func string(for key: String, arguments: CVarArg...) -> String {
        let localized = NSLocalizedString(key, bundle: bundle, comment: "")
        if arguments.isEmpty {
            return localized
        } else {
            return String(format: localized, arguments: arguments)
        }
    }
}

// Notification for language changes
extension Notification.Name {
    static let languageChanged = Notification.Name("LanguageChanged")
}

/// View modifier to handle language changes
struct LanguageAware: ViewModifier {
    @ObservedObject private var localizationHelper = LocalizationHelper.shared

    func body(content: Content) -> some View {
        content
            .environment(\.locale, Locale(identifier: localizationHelper.currentLanguage))
    }
}

extension View {
    /// Make view language aware
    func languageAware() -> some View {
        self.modifier(LanguageAware())
    }
}