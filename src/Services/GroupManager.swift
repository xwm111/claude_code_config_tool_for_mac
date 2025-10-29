//
//  GroupManager.swift
//  ClaudeCodeConfig
//
//  Created by weiming on 2025-10-29.
//  Copyright © 2025 weiming. All rights reserved.
//

import Foundation
import Combine

/// Manages configuration groups with persistence
class GroupManager: ObservableObject {
    static let shared = GroupManager()

    @Published var groups: [ConfigGroup] = []
    private let groupsURL: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDir = appSupport.appendingPathComponent("cccfg")
        try? FileManager.default.createDirectory(at: appDir, withIntermediateDirectories: true)
        groupsURL = appDir.appendingPathComponent("groups.json")

        groups = loadGroups()
        if groups.isEmpty || !groups.contains(where: { $0.id == ConfigGroup.defaultGroupId }) {
            groups = [ConfigGroup()]
            saveGroups()
        }
    }

    /// Saves groups to persistent storage
    func saveGroups() {
        do {
            let data = try encoder.encode(groups)
            try data.write(to: groupsURL)
        } catch {
            print("❌ 保存分组失败: \(error.localizedDescription)")
        }
    }

    /// Loads groups from persistent storage
    func loadGroups() -> [ConfigGroup] {
        guard FileManager.default.fileExists(atPath: groupsURL.path) else {
            return []
        }

        do {
            let data = try Data(contentsOf: groupsURL)
            return try decoder.decode([ConfigGroup].self, from: data)
        } catch {
            print("❌ 加载分组失败: \(error.localizedDescription)")
            return []
        }
    }

    /// Adds a new group
    func addGroup(_ group: ConfigGroup) {
        groups.append(group)
        groups.sort { $0.sortOrder < $1.sortOrder }
        saveGroups()
    }

    /// Deletes a group (except default group)
    func deleteGroup(_ group: ConfigGroup) {
        // 不允许删除默认分组
        if group.id == ConfigGroup.defaultGroupId {
            return
        }
        groups.removeAll { $0.id == group.id }
        saveGroups()
    }

    /// Updates an existing group
    func updateGroup(_ group: ConfigGroup) {
        // 不允许更新默认分组的ID
        guard let index = groups.firstIndex(where: { $0.id == group.id }) else {
            return
        }
        groups[index] = group
        saveGroups()
    }

    /// Gets group by ID
    func getGroup(by id: UUID) -> ConfigGroup? {
        return groups.first { $0.id == id }
    }

    /// Gets the default group
    func getDefaultGroup() -> ConfigGroup {
        return groups.first { $0.id == ConfigGroup.defaultGroupId } ?? ConfigGroup()
    }
}