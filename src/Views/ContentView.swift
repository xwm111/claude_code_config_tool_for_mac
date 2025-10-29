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
    @State private var showingDeleteConfigAlert = false
    @State private var configToDelete: Config?

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
            // 增强的赛博朋克背景
            cyberBackground
                .ignoresSafeArea()

            // 网格叠加层
            Canvas { context, size in
                context.stroke(
                    Path { path in
                        // 垂直线
                        for x in stride(from: 0, through: size.width, by: 30) {
                            path.move(to: CGPoint(x: x, y: 0))
                            path.addLine(to: CGPoint(x: x, y: size.height))
                        }
                        // 水平线
                        for y in stride(from: 0, through: size.height, by: 30) {
                            path.move(to: CGPoint(x: 0, y: y))
                            path.addLine(to: CGPoint(x: size.width, y: y))
                        }
                    },
                    with: .color(.white.opacity(0.03)),
                    lineWidth: 0.5
                )
            }
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // 赛博朋克标题区域 - 重新设计
                VStack(spacing: 16) {
                    // 顶部状态栏
                    HStack {
                        // 系统状态指示器
                        HStack(spacing: 8) {
                            Circle()
                                .fill(AppConstants.Colors.cyberGreen)
                                .frame(width: 8, height: 8)
                                .shadow(color: AppConstants.Colors.cyberGreen, radius: 4)

                            Text("SYSTEM ONLINE")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(AppConstants.Colors.cyberGreen)
                        }

                        Spacer()

                        // 版本信息
                        Text("v\(AppConstants.version)")
                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                            .foregroundColor(AppConstants.Colors.textSecondary)

                        // 退出按钮 - 重新设计
                        Button(action: {
                            NSApplication.shared.terminate(nil)
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "power")
                                    .font(.system(size: 10, weight: .bold))
                                Text("SHUTDOWN")
                                    .font(.system(size: 10, weight: .black, design: .monospaced))
                            }
                            .foregroundColor(.black)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(AppConstants.Colors.cyberRed)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(Color.black, lineWidth: 1)
                                    )
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                    // 主标题区域 - 更具冲击力
                    VStack(spacing: 8) {
                        HStack(spacing: 0) {
                            Text("[")
                                .font(.system(size: 48, weight: .black, design: .monospaced))
                                .foregroundColor(AppConstants.Colors.cyberRed)
                                .shadow(color: AppConstants.Colors.cyberRed, radius: 8)

                            Text("CCC")
                                .font(.system(size: 56, weight: .black, design: .monospaced))
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
                                .shadow(color: AppConstants.Colors.cyberBlue, radius: 12, x: 0, y: 0)

                            Text("]")
                                .font(.system(size: 48, weight: .black, design: .monospaced))
                                .foregroundColor(AppConstants.Colors.cyberRed)
                                .shadow(color: AppConstants.Colors.cyberRed, radius: 8)
                        }

                        Text("◇ NEURAL CONFIGURATION INTERFACE ◇")
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(AppConstants.Colors.cyberGreen)
                            .shadow(color: AppConstants.Colors.cyberGreen, radius: 6)

                        // 分隔线
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        AppConstants.Colors.cyberBlue.opacity(0),
                                        AppConstants.Colors.cyberBlue,
                                        AppConstants.Colors.cyberBlue.opacity(0)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(height: 2)
                            .padding(.horizontal, 100)
                    }
                    .padding(.vertical, 24)
                }

                // 数据控制面板
                VStack(spacing: 20) {
                    // 分组选择器 - 重新设计
                    VStack(spacing: 12) {
                        HStack {
                            Text("◆ NODE SELECTION")
                                .font(.system(size: 14, weight: .black, design: .monospaced))
                                .foregroundColor(AppConstants.Colors.cyberBlue)
                                .shadow(color: AppConstants.Colors.cyberBlue, radius: 4)

                            Spacer()

                            Text("▶ ACCESS TERMINAL")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(AppConstants.Colors.cyberGreen)
                                .shadow(color: AppConstants.Colors.cyberGreen, radius: 3)
                        }

                        CollapsibleGroupSelector(
                            groups: groupManager.groups,
                            configs: configs,
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
                    }

                    // 配置列表 - 重新设计框架
                    VStack(spacing: 12) {
                        HStack {
                            Text("◆ CONFIGURATION MATRIX")
                                .font(.system(size: 14, weight: .black, design: .monospaced))
                                .foregroundColor(AppConstants.Colors.cyberBlue)
                                .shadow(color: AppConstants.Colors.cyberBlue, radius: 4)

                            Spacer()

                            Text("ACTIVE NODES: \(filteredConfigs.count)")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(AppConstants.Colors.cyberGreen)
                                .shadow(color: AppConstants.Colors.cyberGreen, radius: 3)
                        }

                        // 配置列表容器
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(filteredConfigs) { config in
                                    ConfigRowView(
                                        config: config,
                                        groupManager: groupManager,
                                        launcher: launcher,
                                        onEdit: {
                                            editingConfig = config
                                            showingAddConfig = true
                                        },
                                        onDelete: {
                                            configToDelete = config
                                            showingDeleteConfigAlert = true
                                        },
                                        onCopy: { copyConfigCommand(config) },
                                        onDuplicate: {
                                            let newConfig = Config(
                                                name: "\(config.name) 副本",
                                                apiUrl: config.apiUrl,
                                                apiKey: config.apiKey,
                                                workingDirectory: config.workingDirectory,
                                                modelName: config.modelName,
                                                isDefault: false,
                                                isDangerousMode: config.isDangerousMode,
                                                groupId: config.groupId
                                            )
                                            configs.append(newConfig)
                                            configManager.saveConfigs(configs)
                                        },
                                        getGroupColor: getGroupColor,
                                        onShowToast: { toastManager.showToast($0) }
                                    )
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 16)
                        }
                        .frame(maxHeight: 500)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(AppConstants.Colors.panelBackground.opacity(0.3))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            LinearGradient(
                                                colors: [
                                                    AppConstants.Colors.cyberBlue.opacity(0.3),
                                                    AppConstants.Colors.cyberGreen.opacity(0.3)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1
                                        )
                                )
                        )
                    }
                }
                .padding(.horizontal, 32)

                Spacer()

                // 操作控制区域
                VStack(spacing: 20) {
                    Button(action: { showingAddConfig = true }) {
                        HStack(spacing: 16) {
                            Text("[+]")
                                .font(.system(size: 20, weight: .black, design: .monospaced))
                                .foregroundColor(.black)

                            Text("CREATE NEW CONFIG")
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                .foregroundColor(.black)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            AppConstants.Colors.cyberGreen,
                                            AppConstants.Colors.cyberBlue
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.black, lineWidth: 2)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .shadow(color: AppConstants.Colors.cyberGreen, radius: 12, x: 0, y: 0)

                    // 系统信息面板
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("SYSTEM_ARCHITECT: \(AppConstants.developer)")
                                .font(.system(size: 9, weight: .medium, design: .monospaced))
                                .foregroundColor(AppConstants.Colors.textSecondary)

                            Text("CONTACT_PROTOCOL: \(AppConstants.developerEmail)")
                                .font(.system(size: 8, weight: .regular, design: .monospaced))
                                .foregroundColor(AppConstants.Colors.textSecondary.opacity(0.7))
                        }

                        Spacer()

                        // 状态指示器
                        HStack(spacing: 8) {
                            Circle()
                                .fill(AppConstants.Colors.cyberGreen)
                                .frame(width: 6, height: 6)
                                .shadow(color: AppConstants.Colors.cyberGreen, radius: 2)

                            Text("READY")
                                .font(.system(size: 8, weight: .bold, design: .monospaced))
                                .foregroundColor(AppConstants.Colors.cyberGreen)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(AppConstants.Colors.panelBackground.opacity(0.5))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                AppConstants.Colors.cyberBlue.opacity(0.3),
                                                AppConstants.Colors.cyberRed.opacity(0.3)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                    )
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
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
        .alert("删除配置", isPresented: $showingDeleteConfigAlert) {
            Button("取消", role: .cancel) { }
            Button("删除", role: .destructive) {
                if let config = configToDelete {
                    configs.removeAll { $0.id == config.id }
                    configManager.saveConfigs(configs)
                    toastManager.showToast("配置已删除")
                    configToDelete = nil
                }
            }
        } message: {
            Text("确定要删除配置 \"\(configToDelete?.name ?? "")\" 吗？此操作不可撤销。")
        }
        .overlay(
            CyberpunkToast(
                message: toastManager.toastMessage,
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
    let configs: [Config]
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

                        Text(selectedGroupId == nil ? "all groups(\(configs.count))" :
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
                        name: "all groups",
                        count: configs.count,
                        color: AppConstants.Colors.cyberBlue,
                        isSelected: selectedGroupId == nil,
                        onSelect: { selectedGroupId = nil }
                    )

                    // 各个分组
                    ForEach(groups) { group in
                        GroupOptionRow(
                            name: group.name,
                            count: configs.filter { $0.groupId == group.id }.count,
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
    let onDuplicate: () -> Void
    let getGroupColor: (String) -> Color
    let onShowToast: (String) -> Void

    var body: some View {
        ZStack {
            // 背景 - 渐变边框效果
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.15, green: 0.1, blue: 0.25),
                            Color(red: 0.1, green: 0.05, blue: 0.2),
                            Color(red: 0.08, green: 0.03, blue: 0.15)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    AppConstants.Colors.cyberBlue,
                                    AppConstants.Colors.cyberGreen,
                                    AppConstants.Colors.cyberRed
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
                .shadow(color: AppConstants.Colors.cyberBlue.opacity(0.4), radius: 8, x: 0, y: 0)

            VStack(spacing: 16) {
                // 顶部状态栏
                HStack {
                    // 节点标识
                    HStack(spacing: 8) {
                        if let group = groupManager.getGroup(by: config.groupId) {
                            Circle()
                                .fill(getGroupColor(group.color))
                                .frame(width: 10, height: 10)
                                .shadow(color: getGroupColor(group.color), radius: 4)

                            Text(group.name.uppercased())
                                .font(.system(size: 10, weight: .black, design: .monospaced))
                                .foregroundColor(getGroupColor(group.color))
                                .shadow(color: getGroupColor(group.color), radius: 3)
                        }
                    }

                    Spacer()

                    // 状态指示器
                    HStack(spacing: 12) {
                        if config.isDangerousMode {
                            HStack(spacing: 4) {
                                Text("⚠")
                                    .font(.system(size: 10, weight: .bold))
                                Text("DANGER_MODE")
                                    .font(.system(size: 9, weight: .black, design: .monospaced))
                            }
                            .foregroundColor(AppConstants.Colors.cyberRed)
                            .shadow(color: AppConstants.Colors.cyberRed, radius: 3)
                        }

                        Circle()
                            .fill(AppConstants.Colors.cyberGreen)
                            .frame(width: 6, height: 6)
                            .shadow(color: AppConstants.Colors.cyberGreen, radius: 2)

                        Text("ACTIVE")
                            .font(.system(size: 8, weight: .bold, design: .monospaced))
                            .foregroundColor(AppConstants.Colors.cyberGreen)
                    }
                }

                // 主要内容区域
                VStack(alignment: .leading, spacing: 12) {
                    // 配置名称
                    Text(config.name.uppercased())
                        .font(.system(size: 20, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                        .shadow(color: AppConstants.Colors.cyberBlue, radius: 6)

                    // 路径信息
                    HStack {
                        Text("PATH:")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(AppConstants.Colors.cyberGreen)

                        Text(config.workingDirectory)
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(AppConstants.Colors.textSecondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }

                    // API信息
                    HStack {
                        Text("API:")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(AppConstants.Colors.cyberGreen)

                        Text(config.apiUrl)
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(AppConstants.Colors.textSecondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                }

                // 控制按钮区域
                HStack(spacing: 8) {
                    Button(action: {
                        onCopy()
                    }) {
                        Text("[COPY_CMD]")
                            .font(.system(size: 10, weight: .black, design: .monospaced))
                            .foregroundColor(.black)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(AppConstants.Colors.cyberBlue)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(Color.black, lineWidth: 1)
                                    )
                            )
                    }
                    .buttonStyle(PlainButtonStyle())

                    Button(action: {
                        onDuplicate()
                        onShowToast("已创建 \(config.name) 副本")
                    }) {
                        Text("[DUPLICATE]")
                            .font(.system(size: 10, weight: .black, design: .monospaced))
                            .foregroundColor(.black)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(AppConstants.Colors.cyberPurple)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(Color.black, lineWidth: 1)
                                    )
                            )
                    }
                    .buttonStyle(PlainButtonStyle())

                    Button(action: {
                        launcher.launchConfiguration(config)
                    }) {
                        HStack(spacing: 4) {
                            if launcher.isLaunching {
                                ProgressView()
                                    .scaleEffect(0.6)
                                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                            }
                            
                            Text(launcher.isLaunching ? "[LAUNCHING...]" : "[LAUNCH]")
                                .font(.system(size: 10, weight: .black, design: .monospaced))
                                .foregroundColor(.black)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(launcher.isLaunching ? AppConstants.Colors.cyberBlue : AppConstants.Colors.cyberGreen)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.black, lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(launcher.isLaunching)

                    Button(action: {
                        onEdit()
                    }) {
                        Text("[EDIT]")
                            .font(.system(size: 10, weight: .black, design: .monospaced))
                            .foregroundColor(.black)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(AppConstants.Colors.cyberOrange)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(Color.black, lineWidth: 1)
                                    )
                            )
                    }
                    .buttonStyle(PlainButtonStyle())

                    Button(action: {
                        onDelete()
                    }) {
                        Text("[DELETE]")
                            .font(.system(size: 10, weight: .black, design: .monospaced))
                            .foregroundColor(.black)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(AppConstants.Colors.cyberRed)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(Color.black, lineWidth: 1)
                                    )
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(20)
        }
    }
}