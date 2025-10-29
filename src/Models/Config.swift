//
//  Config.swift
//  ClaudeCodeConfig
//
//  Created by weiming on 2025-10-29.
//  Copyright © 2025 weiming. All rights reserved.
//

import Foundation

/// Configuration data model for Claude CLI settings
struct Config: Identifiable, Codable {
    var id = UUID()
    var name: String = ""
    var apiUrl: String = "https://api.anthropic.com"
    var apiKey: String = ""
    var workingDirectory: String = ""
    var modelName: String = ""
    var isDefault: Bool = false
    var isDangerousMode: Bool = false
    var groupId: UUID = ConfigGroup.defaultGroupId

    /// Validates if the configuration has all required fields
    var isValid: Bool {
        !name.isEmpty &&
        !apiUrl.isEmpty &&
        apiUrl.hasPrefix("http") &&
        !apiKey.isEmpty &&
        !workingDirectory.isEmpty
    }

    enum CodingKeys: String, CodingKey {
        case id, name, apiUrl, apiKey, workingDirectory, modelName, isDefault, isDangerousMode, groupId
    }

    init() {
        self.id = UUID()
        self.name = ""
        self.apiUrl = "https://api.anthropic.com"
        self.apiKey = ""
        self.workingDirectory = ""
        self.modelName = ""
        self.isDefault = false
        self.isDangerousMode = false
        self.groupId = ConfigGroup.defaultGroupId
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        apiUrl = try container.decode(String.self, forKey: .apiUrl)
        apiKey = try container.decode(String.self, forKey: .apiKey)
        workingDirectory = try container.decode(String.self, forKey: .workingDirectory)
        modelName = (try? container.decode(String.self, forKey: .modelName)) ?? ""
        isDefault = try container.decode(Bool.self, forKey: .isDefault)
        isDangerousMode = (try? container.decode(Bool.self, forKey: .isDangerousMode)) ?? false
        groupId = (try? container.decode(UUID.self, forKey: .groupId)) ?? ConfigGroup.defaultGroupId
    }

    init(name: String, apiUrl: String, apiKey: String, workingDirectory: String, modelName: String = "", isDefault: Bool = false, isDangerousMode: Bool = false, groupId: UUID = ConfigGroup.defaultGroupId) {
        self.id = UUID()
        self.name = name
        self.apiUrl = apiUrl
        self.apiKey = apiKey
        self.workingDirectory = workingDirectory
        self.modelName = modelName
        self.isDefault = isDefault
        self.isDangerousMode = isDangerousMode
        self.groupId = groupId
    }
}