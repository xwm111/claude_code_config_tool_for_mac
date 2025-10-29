//
//  ConfigGroup.swift
//  ClaudeCodeConfig
//
//  Created by weiming on 2025-10-29.
//  Copyright © 2025 weiming. All rights reserved.
//

import Foundation

/// Configuration group data model for organizing configurations
struct ConfigGroup: Identifiable, Codable {
    var id = UUID()
    var name: String = ""
    var color: String = "blue"
    var icon: String = "folder"
    var sortOrder: Int = 0

    /// Default group ID for ungrouped configurations
    static let defaultGroupId = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!

    /// Available colors for group identification
    static let availableColors: [(name: String, displayName: String)] = [
        ("blue", "蓝色"),
        ("green", "绿色"),
        ("red", "红色"),
        ("orange", "橙色"),
        ("purple", "紫色"),
        ("pink", "粉色")
    ]

    init() {
        self.id = ConfigGroup.defaultGroupId
        self.name = "默认分组"
        self.color = "blue"
        self.icon = "folder"
        self.sortOrder = 0
    }

    init(name: String, color: String = "blue", icon: String = "folder") {
        self.id = UUID()
        self.name = name
        self.color = color
        self.icon = icon
        self.sortOrder = 0
    }

    init(id: UUID, name: String, color: String = "blue", icon: String = "folder", sortOrder: Int = 0) {
        self.id = id
        self.name = name
        self.color = color
        self.icon = icon
        self.sortOrder = sortOrder
    }

    /// Gets the display color for SwiftUI
    var displayColor: String {
        switch color.lowercased() {
        case "green": return "cyberGreen"
        case "red": return "cyberRed"
        case "orange": return "cyberOrange"
        case "purple": return "cyberPurple"
        case "pink": return "cyberPink"
        default: return "cyberBlue"
        }
    }

    /// Validates if the group has valid data
    var isValid: Bool {
        !name.isEmpty && ConfigGroup.availableColors.contains(where: { $0.name == color.lowercased() })
    }
}