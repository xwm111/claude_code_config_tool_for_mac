//
//  Constants.swift
//  ClaudeCodeConfig
//
//  Created by weiming on 2025-10-29.
//  Copyright © 2025 weiming. All rights reserved.
//

import SwiftUI
import Foundation

/// Application-wide constants
struct AppConstants {

    // MARK: - App Information
    static let appName = "Claude Code Config"
    static let bundleIdentifier = "com.claudecode.config"
    static let version = "1.1.4"
    static let developer = "weiming"
    static let developerEmail = "swimming.xwm@gmail.com"

    // MARK: - File Paths
    static let nodePath = "/Users/weimingxu/.nvm/versions/node/v22.14.0/bin"
    static let appSupportDirectoryName = "cccfg"
    static let configsFileName = "configs.json"
    static let groupsFileName = "groups.json"

    // MARK: - UI Constants
    static let windowWidth: CGFloat = 800
    static let windowHeight: CGFloat = 600
    static let minWindowWidth: CGFloat = 600
    static let minWindowHeight: CGFloat = 500

    // MARK: - Cyberpunk Colors
    struct Colors {
        static let cyberBlue = Color(red: 0, green: 0.8, blue: 1.0)
        static let cyberGreen = Color(red: 0, green: 1.0, blue: 0.6)
        static let cyberRed = Color(red: 1.0, green: 0.2, blue: 0.4)
        static let cyberOrange = Color(red: 1.0, green: 0.6, blue: 0.0)
        static let cyberPurple = Color(red: 0.8, green: 0.0, blue: 1.0)
        static let cyberPink = Color(red: 1.0, green: 0.4, blue: 0.8)
        static let darkBackground = Color(red: 0.1, green: 0.1, blue: 0.15)
        static let panelBackground = Color(red: 0.15, green: 0.15, blue: 0.2)
        static let textPrimary = Color.white
        static let textSecondary = Color(red: 0.7, green: 0.7, blue: 0.8)
    }

    // MARK: - Animations
    struct Animations {
        static let defaultDuration: Double = 0.3
        static let fastDuration: Double = 0.15
        static let slowDuration: Double = 0.5
    }

    // MARK: - Validation
    struct Validation {
        static let maxNameLength = 100
        static let maxUrlLength = 500
        static let maxApiKeyLength = 200
        static let maxModelNameLength = 50
        static let maxWorkingDirectoryLength = 500
    }

    // MARK: - Status Messages
    struct Messages {
        static let configSaved = "✅ 配置已保存"
        static let configDeleted = "🗑️ 配置已删除"
        static let launchSuccess = "✅ 启动命令已复制到剪贴板"
        static let configInvalid = "❌ 配置无效"
        static let launching = "🚀 正在启动..."
    }
}

/// Cyberpunk theme extensions
extension Color {
    static let cyberBlue = AppConstants.Colors.cyberBlue
    static let cyberGreen = AppConstants.Colors.cyberGreen
    static let cyberRed = AppConstants.Colors.cyberRed
    static let cyberOrange = AppConstants.Colors.cyberOrange
    static let cyberPurple = AppConstants.Colors.cyberPurple
    static let cyberPink = AppConstants.Colors.cyberPink
}