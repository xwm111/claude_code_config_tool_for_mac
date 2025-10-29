//
//  ContentView.swift
//  ClaudeCodeConfig
//
//  Created by weiming on 2025-10-29.
//  Copyright © 2025 weiming. All rights reserved.
//

import SwiftUI
import AppKit
import Combine

/// Main application view with cyberpunk styling
struct ContentView: View {
    @StateObject private var configManager = ConfigManager.shared
    @StateObject private var groupManager = GroupManager.shared
    @StateObject private var launcher = CLILauncher()
    @State private var configs: [Config] = []
    @State private var showingAddConfig = false
    @State private var editingConfig: Config?
    @State private var showingAddGroup = false
    @State private var editingGroup: ConfigGroup?
    @State private var selectedGroupId: UUID? = nil
    @StateObject private var toastManager = ToastManager.shared
    @State private var showingDeleteGroupAlert = false
    @State private var groupToDelete: ConfigGroup?

    private var filteredConfigs: [Config] {
        if let selectedGroupId = selectedGroupId {
            return configs.filter { $0.groupId == selectedGroupId }
        } else {
            return configs
        }
    }

    // 根据分组颜色字符串获取对应的颜色
    private func getGroupColor(_ colorString: String) -> Color {
        switch colorString {
        case "blue": return Color(red: 0.0, green: 1.0, blue: 1.0) // 霓虹蓝
        case "green": return Color(red: 0.0, green: 1.0, blue: 0.5) // 赛博绿
        case "red": return Color(red: 1.0, green: 0.0, blue: 0.5) // 霓虹粉
        case "orange": return Color(red: 1.0, green: 0.5, blue: 0.0) // 电光橙
        case "purple": return Color(red: 0.8, green: 0.0, blue: 1.0) // 赛博紫
        case "pink": return Color(red: 1.0, green: 0.2, blue: 0.8) // 霓虹紫
        default: return Color(red: 0.0, green: 1.0, blue: 1.0)
        }
    }

    // 赛博朋克背景渐变
    private var cyberBackground: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.05, green: 0.0, blue: 0.1), // 深空蓝
                Color(red: 0.1, green: 0.05, blue: 0.15), // 暗紫
                Color(red: 0.02, green: 0.0, blue: 0.08)  // 深蓝紫
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        ZStack {
            // 赛博朋克背景
            cyberBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // 赛博朋克标题区域
                VStack(spacing: 12) {
                    // 主标题
                    HStack {
                        Text("⚡")
                            .font(.system(size: 28, weight: .black))
                            .foregroundStyle(AppConstants.Colors.cyberBlue)

                        Text("CCC CONFIG")
                            .font(.system(size: 32, weight: .black, design: .monospaced))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        AppConstants.Colors.cyberBlue,
                                        AppConstants.Colors.cyberGreen
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: AppConstants.Colors.cyberBlue, radius: 4, x: 0, y: 0)

                        Spacer()

                        // 退出按钮
                        Button(action: {
                            NSApplication.shared.terminate(nil)
                        }) {
                            Text("⚡ EXIT")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(AppConstants.Colors.cyberRed)
                                        .opacity(0.8)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)

                    // 副标题
                    Text("◇ CLAUDE CODE CLI 配置管理工具 ◇")
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundColor(AppConstants.Colors.cyberGreen)
                }
                .padding(.bottom, 20)

                // 分组选择器
                CollapsibleGroupSelector(
                    groups: groupManager.groups,
                    selectedGroupId: $selectedGroupId,
                    onAddGroup: { showingAddGroup = true },
                    onEditGroup: { group in
                        editingGroup = group
                        showingAddGroup = true
                    },
                    onDeleteGroup: { group in
                        groupToDelete = group
                        showingDeleteGroupAlert = true
                    },
                    getGroupColor: getGroupColor
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 16)

                // 配置列表
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredConfigs) { config in
                            ConfigRowView(
                                config: config,
                                groupManager: groupManager,
                                launcher: launcher,
                                onEdit: {
                                    editingConfig = config
                                    showingAddConfig = true
                                },
                                onDelete: { deleteConfig(config) },
                                onCopy: { copyConfigCommand(config) },
                                getGroupColor: getGroupColor
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                }

                Spacer()

                // 底部操作区域
                VStack(spacing: 16) {
                    Button(action: { showingAddConfig = true }) {
                        HStack {
                            Text("⚡")
                                .font(.system(size: 16, weight: .bold))
                            Text("ADD NEW CONFIG")
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            AppConstants.Colors.cyberBlue,
                                            AppConstants.Colors.cyberGreen
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .opacity(0.8)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    

                    // 开发者信息
                    VStack(spacing: 4) {
                        Text("开发者: \(AppConstants.developer)")
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundColor(AppConstants.Colors.textSecondary)

                        Text("联系邮箱: \(AppConstants.developerEmail)")
                            .font(.system(size: 10, weight: .regular, design: .monospaced))
                            .foregroundColor(AppConstants.Colors.textSecondary.opacity(0.8))
                    }
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, 24)
            }
        }
        .frame(minWidth: AppConstants.windowWidth, minHeight: AppConstants.windowHeight)
        .onAppear(perform: loadConfigs)
        .sheet(isPresented: $showingAddConfig) {
            ConfigEditView(config: editingConfig) { config in
                saveConfig(config)
                showingAddConfig = false
                editingConfig = nil
            }
        }
        .sheet(isPresented: $showingAddGroup) {
            SimpleGroupEditView(group: editingGroup) { group in
                saveGroup(group)
                showingAddGroup = false
                editingGroup = nil
            }
        }
        .alert("删除分组", isPresented: $showingDeleteGroupAlert) {
            Button("取消", role: .cancel) { }
            Button("删除", role: .destructive) {
                if let group = groupToDelete {
                    deleteGroup(group)
                }
            }
        } message: {
            Text("确定要删除分组 \"\(groupToDelete?.name ?? "")\" 吗？该分组的所有配置将移到默认分组。")
        }
        .overlay(
            CyberpunkToast(
                message: "启动命令已复制到剪贴板",
                isVisible: toastManager.showToast,
                onDismiss: {
                    toastManager.dismissToast()
                }
            )
        )
    }

    private func loadConfigs() {
        configs = configManager.loadConfigs()
    }

    private func saveConfig(_ config: Config) {
        if let index = configs.firstIndex(where: { $0.id == config.id }) {
            configs[index] = config
        } else {
            configs.append(config)
        }
        configManager.saveConfigs(configs)
    }

    private func deleteConfig(_ config: Config) {
        configs.removeAll { $0.id == config.id }
        configManager.saveConfigs(configs)
    }

    private func copyConfigCommand(_ config: Config) {
        launcher.copyLaunchCommand(config)
        toastManager.showToast("启动命令已复制到剪贴板")
    }

    private func saveGroup(_ group: ConfigGroup) {
        if let index = groupManager.groups.firstIndex(where: { $0.id == group.id }) {
            groupManager.groups[index] = group
        } else {
            groupManager.addGroup(group)
        }
    }

    private func deleteGroup(_ group: ConfigGroup) {
        // 将该分组的配置移到默认分组
        for i in configs.indices {
            if configs[i].groupId == group.id {
                configs[i].groupId = ConfigGroup.defaultGroupId
            }
        }
        configManager.saveConfigs(configs)
        groupManager.deleteGroup(group)
    }
}

/// Collapsible group selector component
struct CollapsibleGroupSelector: View {
    let groups: [ConfigGroup]
    @Binding var selectedGroupId: UUID?
    let onAddGroup: () -> Void
    let onEditGroup: (ConfigGroup) -> Void
    let onDeleteGroup: (ConfigGroup) -> Void
    let getGroupColor: (String) -> Color

    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 12) {
            // 分组选择器头部
            HStack {
                Button(action: { isExpanded.toggle() }) {
                    HStack(spacing: 8) {
                        Text(isExpanded ? "▼" : "▶")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(AppConstants.Colors.cyberGreen)

                        Text(selectedGroupId == nil ? "全部配置(\(groups.reduce(0) { count, _ in count + 1 }))" :
                             (groups.first { $0.id == selectedGroupId }?.name ?? "未知分组"))
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                

                Spacer()

                // 新建分组按钮
                Button(action: onAddGroup) {
                    Text("+")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(AppConstants.Colors.cyberBlue)
                        .frame(width: 24, height: 24)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(AppConstants.Colors.cyberBlue, lineWidth: 1)
                        )
                }
                .buttonStyle(PlainButtonStyle())
                
            }

            // 展开的分组列表
            if isExpanded {
                VStack(spacing: 8) {
                    // 全部配置选项
                    GroupOptionRow(
                        name: "全部配置",
                        count: groups.reduce(0) { total, group in
                            total + 1 // 简化计数
                        },
                        color: AppConstants.Colors.cyberBlue,
                        isSelected: selectedGroupId == nil,
                        onSelect: { selectedGroupId = nil }
                    )

                    // 各个分组
                    ForEach(groups) { group in
                        GroupOptionRow(
                            name: group.name,
                            count: 1, // 简化计数
                            color: getGroupColor(group.color),
                            isSelected: selectedGroupId == group.id,
                            onSelect: { selectedGroupId = group.id },
                            onEdit: { onEditGroup(group) },
                            onDelete: group.id != ConfigGroup.defaultGroupId ? { onDeleteGroup(group) } : nil
                        )
                    }
                }
                .padding(.leading, 16)
            }
        }
    }
}

/// Group option row component
struct GroupOptionRow: View {
    let name: String
    let count: Int
    let color: Color
    let isSelected: Bool
    let onSelect: () -> Void
    let onEdit: (() -> Void)?
    let onDelete: (() -> Void)?

    init(name: String, count: Int, color: Color, isSelected: Bool, onSelect: @escaping () -> Void, onEdit: (() -> Void)? = nil, onDelete: (() -> Void)? = nil) {
        self.name = name
        self.count = count
        self.color = color
        self.isSelected = isSelected
        self.onSelect = onSelect
        self.onEdit = onEdit
        self.onDelete = onDelete
    }

    var body: some View {
        HStack {
            Button(action: onSelect) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(color)
                        .frame(width: 8, height: 8)

                    Text("\(name)(\(count))")
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(isSelected ? color : .white)
                }
            }
            .buttonStyle(PlainButtonStyle())
            

            Spacer()

            if let onEdit = onEdit {
                Button(action: onEdit) {
                    Text("✏️")
                        .font(.system(size: 10))
                }
                .buttonStyle(PlainButtonStyle())
                
            }

            if let onDelete = onDelete {
                Button(action: onDelete) {
                    Text("🗑️")
                        .font(.system(size: 10))
                }
                .buttonStyle(PlainButtonStyle())
                
            }
        }
    }
}

/// Configuration row view component
struct ConfigRowView: View {
    let config: Config
    let groupManager: GroupManager
    let launcher: CLILauncher
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onCopy: () -> Void
    let getGroupColor: (String) -> Color

    var body: some View {
        VStack(spacing: 12) {
            // 配置信息
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    // 分组标识
                    if let group = groupManager.getGroup(by: config.groupId) {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(getGroupColor(group.color))
                                .frame(width: 8, height: 8)
                            Text(group.name)
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                                .foregroundColor(getGroupColor(group.color))
                        }
                    }

                    Spacer()

                    if config.isDangerousMode {
                        Text("⚠️ 危险模式")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(AppConstants.Colors.cyberRed)
                    }
                }

                Text(config.name)
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)

                Text(config.workingDirectory)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(AppConstants.Colors.textSecondary)
            }
            .padding()

            // 操作按钮
            HStack(spacing: 12) {
                Button(action: onCopy) {
                    Text("COPY")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(AppConstants.Colors.cyberBlue.opacity(0.8))
                        )
                }
                .buttonStyle(PlainButtonStyle())
                

                Button(action: { launcher.launchConfiguration(config) }) {
                    Text("LAUNCH")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(AppConstants.Colors.cyberGreen.opacity(0.8))
                        )
                }
                .buttonStyle(PlainButtonStyle())
                

                Button(action: onEdit) {
                    Text("EDIT")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(AppConstants.Colors.cyberOrange.opacity(0.8))
                        )
                }
                .buttonStyle(PlainButtonStyle())
                
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppConstants.Colors.panelBackground.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            LinearGradient(
                                colors: [AppConstants.Colors.cyberBlue, AppConstants.Colors.cyberGreen],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }
}