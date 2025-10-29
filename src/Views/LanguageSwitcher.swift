//
//  LanguageSwitcher.swift
//  ClaudeCodeConfig
//
//  Created by weiming on 2025-10-29.
//  Copyright © 2025 weiming. All rights reserved.
//

import SwiftUI

/// Language switcher component
struct LanguageSwitcher: View {
    @StateObject private var localizationHelper = LocalizationHelper.shared

    private let languages: [(code: String, name: String, flag: String)] = [
        ("en", "English", "🇺🇸"),
        ("zh-Hans", "简体中文", "🇨🇳")
    ]

    var body: some View {
        Menu {
            ForEach(languages, id: \.code) { language in
                Button(action: {
                    localizationHelper.setLanguage(language.code)
                }) {
                    HStack {
                        Text(language.flag)
                        Text(language.name)
                        if localizationHelper.currentLanguage == language.code {
                            Spacer()
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 6) {
                if let currentLanguage = languages.first(where: { $0.code == localizationHelper.currentLanguage }) {
                    Text(currentLanguage.flag)
                        .font(.system(size: 12))
                    Text(currentLanguage.name)
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(.white)
                } else {
                    Text("🌐")
                        .font(.system(size: 12))
                    Text("Language")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(.white)
                }

                Image(systemName: "chevron.down")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(AppConstants.Colors.cyberBlue.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(AppConstants.Colors.cyberBlue, lineWidth: 1)
                    )
            )
        }
        .menuStyle(BorderlessButtonMenuStyle())
    }
}

/// Language aware view modifier
struct LanguageAwareView: ViewModifier {
    @StateObject private var localizationHelper = LocalizationHelper.shared

    func body(content: Content) -> some View {
        content
            .environment(\.locale, Locale(identifier: localizationHelper.currentLanguage))
            .onReceive(NotificationCenter.default.publisher(for: .languageChanged)) { _ in
                // Force view refresh when language changes
            }
    }
}


#Preview {
    LanguageSwitcher()
        .padding()
        .background(AppConstants.Colors.darkBackground)
}