//
//  ConfigManager.swift
//  ClaudeCodeConfig
//
//  Created by weiming on 2025-10-29.
//  Copyright © 2025 weiming. All rights reserved.
//

import Foundation
import Combine

/// Manages configuration persistence
class ConfigManager: ObservableObject {
    static let shared = ConfigManager()

    private let configURL: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDir = appSupport.appendingPathComponent("cccfg")
        try? FileManager.default.createDirectory(at: appDir, withIntermediateDirectories: true)
        configURL = appDir.appendingPathComponent("configs.json")
    }

    /// Saves configurations to persistent storage
    func saveConfigs(_ configs: [Config]) {
        do {
            let data = try encoder.encode(configs)
            try data.write(to: configURL)
        } catch {
            print("❌ 保存配置失败: \(error.localizedDescription)")
        }
    }

    /// Loads configurations from persistent storage
    func loadConfigs() -> [Config] {
        guard FileManager.default.fileExists(atPath: configURL.path) else {
            return []
        }

        do {
            let data = try Data(contentsOf: configURL)
            return try decoder.decode([Config].self, from: data)
        } catch {
            print("❌ 加载配置失败: \(error.localizedDescription)")
            return []
        }
    }

    /// Gets the file path for config storage
    func getConfigStoragePath() -> String {
        return configURL.path
    }

    /// Validates if the storage directory is accessible
    func validateStorageAccess() -> Bool {
        return FileManager.default.isWritableFile(atPath: configURL.deletingLastPathComponent().path)
    }
}