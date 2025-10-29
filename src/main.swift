//
//  cccfg.swift - 简化版本，确保编译通过
//  包含基本分组功能
//

import SwiftUI
import Foundation
import AppKit

// 窗口管理器
class WindowManager: ObservableObject {
    static let shared = WindowManager()

    private var mainWindow: NSWindow?

    private init() {}

    func setMainWindow(_ window: NSWindow) {
        self.mainWindow = window
    }

    func activateWindow() {
        DispatchQueue.main.async {
            NSApp.activate(ignoringOtherApps: true)
            if let window = self.mainWindow ?? NSApp.keyWindow {
                window.makeKeyAndOrderFront(nil)
                window.level = .normal
            }
        }
    }

    func showWindow() {
        DispatchQueue.main.async {
            NSApp.activate(ignoringOtherApps: true)
            if let window = self.mainWindow ?? NSApp.keyWindow {
                window.makeKeyAndOrderFront(nil)
                window.level = .normal
            }
        }
    }
}

// 应用程序代理
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var statusMenu: NSMenu?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupEnvironment()
        setupDockIcon()
        setupStatusItem()
        NSApp.setActivationPolicy(.regular)
    }

    private func setupEnvironment() {
        let currentPath = ProcessInfo.processInfo.environment["PATH"] ?? ""
        let nodePath = "/Users/weimingxu/.nvm/versions/node/v22.14.0/bin"
        let newPath = "\(nodePath):\(currentPath)"
        setenv("PATH", newPath, 1)
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            WindowManager.shared.showWindow()
        }
        return true
    }

    private func setupDockIcon() {
        let iconSize = NSSize(width: 512, height: 512)
        let image = NSImage(size: iconSize)
        image.lockFocus()
        let rect = NSRect(origin: .zero, size: iconSize)
        NSColor.controlAccentColor.setFill()
        NSBezierPath(roundedRect: rect, xRadius: 64, yRadius: 64).fill()
        image.unlockFocus()
        NSApplication.shared.applicationIconImage = image
    }

    private func setupStatusItem() {
        // 创建状态栏项目
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            // 使用应用图标
            if let icon = NSImage(systemSymbolName: "gear.circle.fill", accessibilityDescription: nil) {
                icon.size = NSSize(width: 16, height: 16)
                button.image = icon
            }
            button.toolTip = "Claude Code Config"
        }

        setupMenu()
    }

    private func setupMenu() {
        // 创建菜单
        statusMenu = NSMenu()

        // 显示应用菜单项
        let showItem = NSMenuItem(
            title: "显示 Claude Code Config",
            action: #selector(showApplication),
            keyEquivalent: ""
        )
        statusMenu?.addItem(showItem)

        statusMenu?.addItem(NSMenuItem.separator())

        // 配置管理菜单项
        let configItem = NSMenuItem(
            title: "配置管理",
            action: nil,
            keyEquivalent: ""
        )
        statusMenu?.addItem(configItem)

        // 启动配置菜单项
        let launchItem = NSMenuItem(
            title: "启动配置",
            action: #selector(launchConfig),
            keyEquivalent: "L"
        )
        launchItem.keyEquivalentModifierMask = [.command, .shift]
        statusMenu?.addItem(launchItem)

        statusMenu?.addItem(NSMenuItem.separator())

        // 帮助菜单项
        let helpItem = NSMenuItem(
            title: "帮助",
            action: #selector(showHelp),
            keyEquivalent: "?"
        )
        statusMenu?.addItem(helpItem)

        statusMenu?.addItem(NSMenuItem.separator())

        // 退出菜单项
        let quitItem = NSMenuItem(
            title: "退出 Claude Code Config",
            action: #selector(quitApplication),
            keyEquivalent: "q"
        )
        quitItem.keyEquivalentModifierMask = [.command]
        statusMenu?.addItem(quitItem)

        // 设置菜单到状态栏项目
        statusItem?.menu = statusMenu
    }

    @objc private func statusItemClicked() {
        WindowManager.shared.activateWindow()
    }

    @objc private func showApplication() {
        WindowManager.shared.activateWindow()
    }

    @objc private func launchConfig() {
        WindowManager.shared.activateWindow()
        // 发送通知给主视图来启动默认配置
        NotificationCenter.default.post(name: NSNotification.Name("LaunchDefaultConfig"), object: nil)
    }

    @objc private func showHelp() {
        WindowManager.shared.activateWindow()
        // 可以在这里添加帮助功能
        let alert = NSAlert()
        alert.messageText = "Claude Code Config 帮助"
        alert.informativeText = "使用说明：\n1. 点击应用图标显示主窗口\n2. 创建和管理Claude CLI配置\n3. 使用分组功能组织配置\n4. 一键启动开发环境\n\n快捷键：\n• ⌘⇧L: 启动配置\n• ⌘Q: 退出应用"
        alert.addButton(withTitle: "确定")
        alert.runModal()
    }

    @objc private func quitApplication() {
        NSApplication.shared.terminate(nil)
    }
}

// 简化的分组模型
struct ConfigGroup: Identifiable, Codable {
    var id = UUID()
    var name: String = ""
    var color: String = "blue"
    var icon: String = "folder"
    var sortOrder: Int = 0

    static let defaultGroupId = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!

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
}

// 分组管理器
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

    func saveGroups() {
        do {
            let data = try encoder.encode(groups)
            try data.write(to: groupsURL)
        } catch {
            print("❌ 保存分组失败: \(error.localizedDescription)")
        }
    }

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

    func addGroup(_ group: ConfigGroup) {
        groups.append(group)
        groups.sort { $0.sortOrder < $1.sortOrder }
        saveGroups()
    }

    func deleteGroup(_ group: ConfigGroup) {
        // 不允许删除默认分组
        if group.id == ConfigGroup.defaultGroupId {
            return
        }
        groups.removeAll { $0.id == group.id }
        saveGroups()
    }

    func updateGroup(_ group: ConfigGroup) {
        // 不允许更新默认分组的ID
        guard let index = groups.firstIndex(where: { $0.id == group.id }) else {
            return
        }
        groups[index] = group
        saveGroups()
    }
}

// 配置模型
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

    var isValid: Bool {
        !name.isEmpty && !apiUrl.isEmpty && apiUrl.hasPrefix("http") && !apiKey.isEmpty && !workingDirectory.isEmpty
    }

    enum CodingKeys: String, CodingKey {
        case id, name, apiUrl, apiKey, workingDirectory, modelName, isDefault, isDangerousMode, groupId
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
}

// 启动器类
class CLILauncher: ObservableObject {
    @Published var isLaunching = false
    @Published var launchStatus = ""

    func launchConfiguration(_ config: Config) {
        guard config.isValid else {
            launchStatus = "❌ 配置无效"
            return
        }

        isLaunching = true
        launchStatus = "🚀 正在启动..."

        // 构建启动命令
        var command = "export PATH=\"/Users/weimingxu/.nvm/versions/node/v22.14.0/bin:$PATH\" && "
        command += "ANTHROPIC_AUTH_TOKEN=\"\(config.apiKey)\" "
        command += "ANTHROPIC_BASE_URL=\"\(config.apiUrl)\" "

        if !config.modelName.isEmpty {
            command += "ANTHROPIC_MODEL=\"\(config.modelName)\" "
        }

        command += "claude"

        // 添加危险模式参数
        if config.isDangerousMode {
            command += " --dangerously-skip-permissions"
        }

        if !config.workingDirectory.isEmpty {
            command = "cd \"\(config.workingDirectory)\" && " + command
        }

        // 复制到剪贴板
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(command, forType: .string)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isLaunching = false
            self.launchStatus = "✅ 启动命令已复制到剪贴板"
        }
    }

    func copyLaunchCommand(_ config: Config) {
        var command = "export PATH=\"/Users/weimingxu/.nvm/versions/node/v22.14.0/bin:$PATH\" && "
        command += "ANTHROPIC_AUTH_TOKEN=\"\(config.apiKey)\" "
        command += "ANTHROPIC_BASE_URL=\"\(config.apiUrl)\" "

        if !config.modelName.isEmpty {
            command += "ANTHROPIC_MODEL=\"\(config.modelName)\" "
        }

        command += "claude"

        if config.isDangerousMode {
            command += " --dangerously-skip-permissions"
        }

        if !config.workingDirectory.isEmpty {
            command = "cd \"\(config.workingDirectory)\" && " + command
        }

        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(command, forType: .string)
    }
}

// 配置管理器
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

    func saveConfigs(_ configs: [Config]) {
        do {
            let data = try encoder.encode(configs)
            try data.write(to: configURL)
        } catch {
            print("❌ 保存配置失败: \(error.localizedDescription)")
        }
    }

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
}

// 简化的配置编辑视图
struct ConfigEditView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var groupManager = GroupManager.shared
    @State private var config: Config
    @State private var isGroupSelectorExpanded = false
    let onSave: (Config) -> Void
    let isEditing: Bool

    init(config: Config? = nil, onSave: @escaping (Config) -> Void) {
        self.config = config ?? Config()
        self.onSave = onSave
        self.isEditing = config != nil
    }

    // 获取分组颜色（用于编辑视图）
    private func getGroupColorForEdit(_ colorString: String) -> Color {
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

    var body: some View {
        ZStack {
            // 赛博朋克背景
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.0, blue: 0.1),
                    Color(red: 0.1, green: 0.05, blue: 0.15),
                    Color(red: 0.02, green: 0.0, blue: 0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                // 赛博朋克标题
                VStack(spacing: 8) {
                    Text(isEditing ? "[EDIT_CONFIG]" : "[NEW_CONFIG]")
                        .font(.system(size: 24, weight: .black, design: .monospaced))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.0, green: 1.0, blue: 1.0),
                                    Color(red: 0.8, green: 0.0, blue: 1.0)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: Color(red: 0.0, green: 1.0, blue: 1.0), radius: 8, x: 0, y: 0)

                    Text(">> CONFIGURATION PROTOCOL ACTIVE <<")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(Color(red: 0.0, green: 1.0, blue: 0.5))
                }
                .padding(.top, 24)

                ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // 配置名称字段
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Text("◆")
                                .font(.system(size: 12, weight: .black, design: .monospaced))
                                .foregroundColor(Color(red: 1.0, green: 0.0, blue: 0.5))
                            Text("CONFIG_NAME")
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                .foregroundColor(Color(red: 0.0, green: 1.0, blue: 1.0))
                        }
                        TextField("ENTER_CONFIG_NAME", text: $config.name)
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundColor(Color.black)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(red: 0.0, green: 1.0, blue: 1.0), lineWidth: 1)
                                    .background(Color(red: 0.9, green: 0.9, blue: 0.95))
                            )
                            .disableAutocorrection(true)
                    }

                    // API URL字段
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Text("◆")
                                .font(.system(size: 12, weight: .black, design: .monospaced))
                                .foregroundColor(Color(red: 1.0, green: 0.0, blue: 0.5))
                            Text("API_ENDPOINT")
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                .foregroundColor(Color(red: 0.0, green: 1.0, blue: 1.0))
                        }
                        TextField("https://api.anthropic.com", text: $config.apiUrl)
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundColor(Color.black)
                                                        .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(red: 0.0, green: 1.0, blue: 1.0), lineWidth: 1)
                                    .background(Color(red: 0.9, green: 0.9, blue: 0.95))
                            )
                            .disableAutocorrection(true)
                    }

                    // API Key字段
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Text("◆")
                                .font(.system(size: 12, weight: .black, design: .monospaced))
                                .foregroundColor(Color(red: 1.0, green: 0.0, blue: 0.5))
                            Text("API_KEY")
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                .foregroundColor(Color(red: 0.0, green: 1.0, blue: 1.0))
                        }
                        SecureField("sk-ant-api03-...", text: $config.apiKey)
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundColor(Color.black)
                                                        .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(red: 0.0, green: 1.0, blue: 1.0), lineWidth: 1)
                                    .background(Color(red: 0.9, green: 0.9, blue: 0.95))
                            )
                            .disableAutocorrection(true)
                    }

                    // 工作目录字段
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Text("◆")
                                .font(.system(size: 12, weight: .black, design: .monospaced))
                                .foregroundColor(Color(red: 1.0, green: 0.0, blue: 0.5))
                            Text("WORKING_DIRECTORY")
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                .foregroundColor(Color(red: 0.0, green: 1.0, blue: 1.0))
                        }
                        HStack(spacing: 12) {
                            TextField("/path/to/project", text: $config.workingDirectory)
                                .font(.system(size: 13, design: .monospaced))
                                .foregroundColor(Color.black)
                                                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(red: 0.0, green: 1.0, blue: 1.0), lineWidth: 1)
                                        .background(Color(red: 0.9, green: 0.9, blue: 0.95))
                                )
                                .disableAutocorrection(true)

                            Button(action: {
                                selectWorkingDirectory()
                            }) {
                                Text("[BROWSE]")
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .foregroundColor(Color(red: 0.0, green: 1.0, blue: 0.5))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(Color(red: 0.0, green: 1.0, blue: 0.5), lineWidth: 1)
                                            .background(Color(red: 0.0, green: 1.0, blue: 0.5).opacity(0.1))
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    // 分组选择字段
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Text("◆")
                                .font(.system(size: 12, weight: .black, design: .monospaced))
                                .foregroundColor(Color(red: 1.0, green: 0.0, blue: 0.5))
                            Text("PROJECT_GROUP")
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                .foregroundColor(Color(red: 0.0, green: 1.0, blue: 1.0))
                        }

                        // 使用自定义的下拉选择器
                        VStack(spacing: 0) {
                            // 当前选中的分组显示
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isGroupSelectorExpanded.toggle()
                                }
                            }) {
                                HStack {
                                    // 显示当前选中的分组信息
                                    if let selectedGroup = groupManager.groups.first(where: { $0.id == config.groupId }) {
                                        HStack(spacing: 8) {
                                            Text("●")
                                                .font(.system(size: 12, weight: .black, design: .monospaced))
                                                .foregroundColor(getGroupColorForEdit(selectedGroup.color))

                                            Text(selectedGroup.name)
                                                .font(.system(size: 13, weight: .medium, design: .monospaced))
                                                .foregroundColor(Color.black)
                                        }
                                    } else {
                                        Text("SELECT_GROUP")
                                            .font(.system(size: 13, design: .monospaced))
                                            .foregroundColor(Color.black)
                                    }

                                    Spacer()
                                    Text(isGroupSelectorExpanded ? "▲" : "▼")
                                        .font(.system(size: 10, weight: .black, design: .monospaced))
                                        .foregroundColor(Color(red: 0.0, green: 1.0, blue: 1.0))
                                        .animation(.easeInOut(duration: 0.3), value: isGroupSelectorExpanded)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(
                                            groupManager.groups.first(where: { $0.id == config.groupId }) != nil ?
                                            getGroupColorForEdit(groupManager.groups.first(where: { $0.id == config.groupId })?.color ?? "blue") :
                                            Color(red: 0.0, green: 1.0, blue: 1.0),
                                            lineWidth: 1
                                        )
                                        .background(Color(red: 0.9, green: 0.9, blue: 0.95))
                                )
                            }
                            .buttonStyle(.plain)

                            // 分组选项列表（只在展开时显示）
                            if isGroupSelectorExpanded {
                                VStack(spacing: 2) {
                                    ForEach(groupManager.groups) { group in
                                        Button(action: {
                                            config.groupId = group.id
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                isGroupSelectorExpanded = false
                                            }
                                        }) {
                                            HStack(spacing: 10) {
                                                Text("●")
                                                    .font(.system(size: 10, weight: .black, design: .monospaced))
                                                    .foregroundColor(getGroupColorForEdit(group.color))

                                                Text(group.name)
                                                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                                                    .foregroundColor(Color.black)

                                                Spacer()

                                                // 如果这是当前选中的分组，显示选中标记
                                                if config.groupId == group.id {
                                                    Text("✓")
                                                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                                                        .foregroundColor(Color(red: 0.0, green: 1.0, blue: 0.5))
                                                }
                                            }
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 10)
                                            .background(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .fill(config.groupId == group.id ?
                                                        Color(red: 0.8, green: 0.9, blue: 1.0) :
                                                        Color(red: 0.95, green: 0.95, blue: 1.0))
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 6)
                                                            .stroke(getGroupColorForEdit(group.color), lineWidth: config.groupId == group.id ? 2 : 1)
                                                    )
                                            )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.top, 4)
                            }
                        }
                        .background(Color(red: 0.9, green: 0.9, blue: 0.95))
                        .cornerRadius(8)
                        .onTapGesture {
                            if isGroupSelectorExpanded {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    isGroupSelectorExpanded = false
                                }
                            }
                        }
                    }

                    // 危险模式开关
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 10) {
                            Text("⚠")
                                .font(.system(size: 16, weight: .black))
                                .foregroundColor(Color(red: 1.0, green: 0.0, blue: 0.5))

                            Text("DANGER_MODE")
                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                                .foregroundColor(Color(red: 1.0, green: 0.0, blue: 0.5))

                            Spacer()
                        }

                        HStack(spacing: 16) {
                            Text(">> ENABLE ADVANCED PERMISSIONS <<")
                                .font(.system(size: 11, weight: .medium, design: .monospaced))
                                .foregroundColor(Color(red: 0.8, green: 0.8, blue: 0.8))

                            Spacer()

                            // 自定义赛博朋克开关
                            Button(action: {
                                config.isDangerousMode.toggle()
                            }) {
                                HStack(spacing: 8) {
                                    Text(config.isDangerousMode ? "ACTIVE" : "INACTIVE")
                                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                                        .foregroundColor(config.isDangerousMode ? Color(red: 0.0, green: 1.0, blue: 0.5) : Color(red: 0.7, green: 0.7, blue: 0.8))

                                    RoundedRectangle(cornerRadius: 10)
                                        .frame(width: 50, height: 24)
                                        .background(
                                            LinearGradient(
                                                colors: config.isDangerousMode ?
                                                [Color(red: 0.0, green: 1.0, blue: 0.5), Color(red: 0.0, green: 0.8, blue: 0.3)] :
                                                [Color(red: 0.3, green: 0.3, blue: 0.4), Color(red: 0.2, green: 0.2, blue: 0.3)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(config.isDangerousMode ? Color(red: 0.0, green: 1.0, blue: 0.5) : Color(red: 0.5, green: 0.5, blue: 0.6), lineWidth: 1)
                                        )
                                        .overlay(
                                            Circle()
                                                .frame(width: 18, height: 18)
                                                .foregroundColor(Color.black)
                                                .offset(x: config.isDangerousMode ? 13 : -13)
                                                .animation(Animation.easeInOut(duration: 0.2), value: config.isDangerousMode)
                                        )
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(20)
            }

            Spacer()

            // 赛博朋克按钮组
            HStack(spacing: 16) {
                // 取消按钮
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    VStack(spacing: 4) {
                        Text("◆")
                            .font(.system(size: 14, weight: .black, design: .monospaced))
                            .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.8))
                        Text("[CANCEL]")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.8))
                        Text(">> ABORT PROTOCOL <<")
                            .font(.system(size: 8, weight: .medium, design: .monospaced))
                            .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(red: 0.7, green: 0.7, blue: 0.8), lineWidth: 1)
                            .background(Color(red: 0.1, green: 0.1, blue: 0.15).opacity(0.8))
                    )
                }
                .buttonStyle(.plain)

                // 保存/更新按钮
                Button(action: {
                    onSave(config)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    VStack(spacing: 4) {
                        Text("▶")
                            .font(.system(size: 14, weight: .black, design: .monospaced))
                            .foregroundColor(config.isValid ? Color(red: 0.0, green: 1.0, blue: 1.0) : Color(red: 0.5, green: 0.5, blue: 0.6))
                        Text(isEditing ? "[UPDATE]" : "[SAVE]")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(config.isValid ? Color(red: 0.0, green: 1.0, blue: 1.0) : Color(red: 0.5, green: 0.5, blue: 0.6))
                        Text(config.isValid ? ">> COMMIT CONFIG <<" : ">> INVALID INPUT <<")
                            .font(.system(size: 8, weight: .medium, design: .monospaced))
                            .foregroundColor(config.isValid ? Color(red: 0.0, green: 1.0, blue: 0.5) : Color(red: 0.8, green: 0.3, blue: 0.3))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                config.isValid ?
                                LinearGradient(colors: [Color(red: 0.0, green: 1.0, blue: 1.0), Color(red: 0.0, green: 1.0, blue: 0.5)], startPoint: .topLeading, endPoint: .bottomTrailing) :
                                LinearGradient(colors: [Color(red: 0.5, green: 0.5, blue: 0.6), Color(red: 0.4, green: 0.4, blue: 0.5)], startPoint: .topLeading, endPoint: .bottomTrailing),
                                lineWidth: config.isValid ? 2 : 1
                            )
                            .background(
                                config.isValid ?
                                LinearGradient(
                                    colors: [Color(red: 0.0, green: 1.0, blue: 1.0).opacity(0.2), Color(red: 0.0, green: 1.0, blue: 0.5).opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) :
                                LinearGradient(
                                    colors: [Color(red: 0.1, green: 0.1, blue: 0.15).opacity(0.8), Color(red: 0.05, green: 0.05, blue: 0.1).opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                }
                .buttonStyle(.plain)
                .disabled(!config.isValid)
                .shadow(
                    color: config.isValid ? Color(red: 0.0, green: 1.0, blue: 1.0) : Color.clear,
                    radius: config.isValid ? 8 : 0,
                    x: 0,
                    y: 0
                )
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        }
        .frame(minWidth: 500, minHeight: 600)
    }

    private func selectWorkingDirectory() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.title = "选择工作目录"

        if panel.runModal() == .OK {
            config.workingDirectory = panel.url?.path ?? ""
        }
    }
}

// 简化的主视图
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
    @State private var showCopiedAlert = false
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

            // 主要内容
            VStack(spacing: 30) {
                // 赛博朋克标题
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("[ CCC_CONFIG ]")
                                .font(.system(size: 36, weight: .black, design: .monospaced))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.0, green: 1.0, blue: 1.0),
                                            Color(red: 0.8, green: 0.0, blue: 1.0)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: Color(red: 0.0, green: 1.0, blue: 1.0), radius: 10, x: 0, y: 0)

                            Text(">> NEURAL INTERFACE ACTIVE")
                                .font(.system(size: 12, weight: .medium, design: .monospaced))
                                .foregroundColor(Color(red: 0.0, green: 1.0, blue: 0.5))
                        }

                        Spacer()

                        // 赛博朋克退出按钮
                        Button(action: {
                            NSApplication.shared.terminate(nil)
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "power")
                                    .font(.system(size: 12, weight: .bold))
                                Text("[SHUTDOWN]")
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                            }
                            .foregroundColor(Color(red: 1.0, green: 0.0, blue: 0.5))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color(red: 1.0, green: 0.0, blue: 0.5), lineWidth: 1)
                                    .background(Color(red: 1.0, green: 0.0, blue: 0.5).opacity(0.1))
                            )
                        }
                        .buttonStyle(.plain)
                        .shadow(color: Color(red: 1.0, green: 0.0, blue: 0.5), radius: 8, x: 0, y: 0)
                    }

                    // 副标题
                    HStack {
                        Text("┌─ CLAUDE CODE CLI NEURAL CONFIG MANAGER v1.1.4 ─┐")
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundColor(Color(red: 0.0, green: 1.0, blue: 1.0).opacity(0.8))
                        Spacer()
                        Text("└─ SYSTEM STATUS: ONLINE ─┘")
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundColor(Color(red: 0.0, green: 1.0, blue: 0.5))
                    }
                }
                .padding(.top, 40)
                .padding(.horizontal, 30)

            // 赛博朋克分组选择器
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    HStack(spacing: 10) {
                        Text("◆")
                            .font(.system(size: 16, weight: .black, design: .monospaced))
                            .foregroundColor(Color(red: 1.0, green: 0.0, blue: 0.5))
                        Text("PROJECT_GROUPS")
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(Color(red: 0.0, green: 1.0, blue: 1.0))
                    }
                    Spacer()
                    Button(action: {
                        showingAddGroup = true
                    }) {
                        HStack(spacing: 8) {
                            Text("+")
                                .font(.system(size: 14, weight: .black, design: .monospaced))
                                .foregroundColor(Color(red: 0.0, green: 1.0, blue: 0.5))
                            Text("[NEW_GROUP]")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(Color(red: 0.0, green: 1.0, blue: 0.5))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color(red: 0.0, green: 1.0, blue: 0.5), lineWidth: 2)
                                .background(Color(red: 0.0, green: 1.0, blue: 0.5).opacity(0.15))
                        )
                    }
                    .buttonStyle(.plain)
                    .shadow(color: Color(red: 0.0, green: 1.0, blue: 0.5), radius: 8, x: 0, y: 0)
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        // 全部配置
                        Button(action: {
                            selectedGroupId = nil
                        }) {
                            VStack(spacing: 6) {
                                HStack(spacing: 8) {
                                    Text("●")
                                        .font(.system(size: 12, weight: .black, design: .monospaced))
                                        .foregroundColor(selectedGroupId == nil ? Color(red: 0.0, green: 1.0, blue: 1.0) : Color(red: 0.7, green: 0.7, blue: 0.8))
                                    Text("[ALL_CONFIGS]")
                                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                                        .foregroundColor(selectedGroupId == nil ? Color(red: 0.0, green: 1.0, blue: 1.0) : Color(red: 0.9, green: 0.9, blue: 0.9))
                                }
                                Text("(\(configs.count))")
                                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                                    .foregroundColor(selectedGroupId == nil ? Color(red: 0.0, green: 1.0, blue: 0.5) : Color(red: 0.8, green: 0.8, blue: 0.8))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(
                                        selectedGroupId == nil ?
                                        LinearGradient(colors: [Color(red: 0.0, green: 1.0, blue: 1.0), Color(red: 0.8, green: 0.0, blue: 1.0)], startPoint: .topLeading, endPoint: .bottomTrailing) :
                                        LinearGradient(colors: [Color(red: 0.7, green: 0.7, blue: 0.8), Color(red: 0.5, green: 0.5, blue: 0.6)], startPoint: .topLeading, endPoint: .bottomTrailing),
                                        lineWidth: selectedGroupId == nil ? 2 : 1
                                    )
                                    .background(
                                        selectedGroupId == nil ?
                                        LinearGradient(
                                            colors: [Color(red: 0.0, green: 1.0, blue: 1.0).opacity(0.2), Color(red: 0.8, green: 0.0, blue: 1.0).opacity(0.15)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ) :
                                        LinearGradient(
                                            colors: [Color(red: 0.1, green: 0.1, blue: 0.15).opacity(0.8), Color(red: 0.05, green: 0.05, blue: 0.1).opacity(0.8)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                        .shadow(
                            color: selectedGroupId == nil ? Color(red: 0.0, green: 1.0, blue: 1.0) : Color.clear,
                            radius: selectedGroupId == nil ? 10 : 0,
                            x: 0,
                            y: 0
                        )

                        // 各个分组
                        ForEach(groupManager.groups) { group in
                            let groupConfigCount = configs.filter { $0.groupId == group.id }.count
                            Button(action: {
                                selectedGroupId = group.id
                            }) {
                                VStack(spacing: 6) {
                                    HStack(spacing: 8) {
                                        Text("●")
                                            .font(.system(size: 10, weight: .black, design: .monospaced))
                                            .foregroundColor(getGroupColor(group.color))
                                        Text("[\(group.name.uppercased())]")
                                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                                            .foregroundColor(selectedGroupId == group.id ? getGroupColor(group.color) : Color(red: 0.9, green: 0.9, blue: 0.9))

                                        if group.id != ConfigGroup.defaultGroupId {
                                            HStack(spacing: 4) {
                                                Button(action: {
                                                    editingGroup = group
                                                }) {
                                                    Text("⚙")
                                                        .font(.system(size: 9, weight: .black, design: .monospaced))
                                                        .foregroundColor(Color(red: 0.0, green: 1.0, blue: 0.5))
                                                }
                                                .buttonStyle(.plain)

                                                Button(action: {
                                                    groupToDelete = group
                                                    showingDeleteGroupAlert = true
                                                }) {
                                                    Text("✕")
                                                        .font(.system(size: 9, weight: .black, design: .monospaced))
                                                        .foregroundColor(Color(red: 1.0, green: 0.0, blue: 0.5))
                                                }
                                                .buttonStyle(.plain)
                                                .help("删除分组")
                                            }
                                        }
                                    }
                                    Text("(\(groupConfigCount))")
                                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                                        .foregroundColor(selectedGroupId == group.id ? getGroupColor(group.color) : Color(red: 0.8, green: 0.8, blue: 0.8))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(
                                            selectedGroupId == group.id ?
                                            LinearGradient(colors: [getGroupColor(group.color), getGroupColor(group.color).opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing) :
                                            LinearGradient(colors: [getGroupColor(group.color).opacity(0.5), getGroupColor(group.color).opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing),
                                            lineWidth: selectedGroupId == group.id ? 2 : 1
                                        )
                                        .background(
                                            selectedGroupId == group.id ?
                                            LinearGradient(
                                                colors: [getGroupColor(group.color).opacity(0.25), getGroupColor(group.color).opacity(0.1)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ) :
                                            LinearGradient(
                                                colors: [Color(red: 0.1, green: 0.1, blue: 0.15).opacity(0.8), Color(red: 0.05, green: 0.05, blue: 0.1).opacity(0.8)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                            .shadow(
                                color: selectedGroupId == group.id ? getGroupColor(group.color) : Color.clear,
                                radius: selectedGroupId == group.id ? 8 : 0,
                                x: 0,
                                y: 0
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                }
            }
            .padding(.horizontal, 20)

            // 配置列表
            if filteredConfigs.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "gear.badge.plus")
                        .font(.system(size: 64))
                        .foregroundColor(.blue)
                    Text(configs.isEmpty ? "还没有配置" : "该分组暂无配置")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("点击下方按钮创建配置")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredConfigs) { config in
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(config.name)
                                        .font(.headline)
                                        .foregroundColor(.primary)

                                    HStack(spacing: 4) {
                                        if let group = groupManager.groups.first(where: { $0.id == config.groupId }) {
                                            HStack(spacing: 2) {
                                                Circle()
                                                    .fill(getGroupColor(group.color))
                                                    .frame(width: 4, height: 4)

                                                Text(group.name)
                                                    .font(.caption2)
                                            }
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(getGroupColor(group.color).opacity(0.2))
                                            .cornerRadius(4)
                                        }

                                        if config.isDangerousMode {
                                            Text("⚠️ 危险模式")
                                                .font(.caption2)
                                                .foregroundColor(.red)
                                        }

                                        if config.isDefault {
                                            Text("默认")
                                                .font(.caption2)
                                                .foregroundColor(.green)
                                        }
                                    }

                                    if !launcher.launchStatus.isEmpty && launcher.isLaunching {
                                        Text(launcher.launchStatus)
                                            .font(.caption)
                                            .foregroundColor(.orange)
                                    }
                                }

                                Spacer()

                                HStack(spacing: 8) {
                                    Button(action: {
                                        launcher.copyLaunchCommand(config)
                                        showCopiedAlert = true
                                    }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "doc.on.doc")
                                                .font(.system(size: 12))
                                            Text("复制")
                                        }
                                    }
                                    .buttonStyle(.bordered)
                                    .controlSize(.small)

                                    Button(action: {
                                        launcher.launchConfiguration(config)
                                    }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "play.circle.fill")
                                                .font(.system(size: 12))
                                            Text(launcher.isLaunching ? "启动中..." : "启动")
                                        }
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .controlSize(.small)
                                    .disabled(launcher.isLaunching)

                                    Button(action: {
                                        editingConfig = config
                                    }) {
                                        Text("编辑")
                                    }
                                    .buttonStyle(.bordered)
                                    .controlSize(.small)
                                }
                            }
                            .padding()
                            .background(Color(NSColor.controlBackgroundColor))
                            .cornerRadius(8)
                        }
                    }
                    .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            // 赛博朋克添加配置按钮
            Button(action: {
                showingAddConfig = true
            }) {
                VStack(spacing: 8) {
                    HStack(spacing: 12) {
                        Text("▶")
                            .font(.system(size: 16, weight: .black, design: .monospaced))
                            .foregroundColor(Color(red: 0.0, green: 1.0, blue: 1.0))

                        Text("[CREATE_NEW_CONFIG]")
                            .font(.system(size: 16, weight: .black, design: .monospaced))
                            .foregroundColor(Color(red: 0.0, green: 1.0, blue: 1.0))

                        Text("▶")
                            .font(.system(size: 16, weight: .black, design: .monospaced))
                            .foregroundColor(Color(red: 0.0, green: 1.0, blue: 1.0))
                    }
                    Text(">> INITIATE CONFIGURATION PROTOCOL <<")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(Color(red: 0.0, green: 1.0, blue: 0.5))
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 18)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.0, green: 1.0, blue: 1.0),
                                    Color(red: 0.8, green: 0.0, blue: 1.0),
                                    Color(red: 0.0, green: 1.0, blue: 0.5)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.0, green: 1.0, blue: 1.0).opacity(0.15),
                                    Color(red: 0.8, green: 0.0, blue: 1.0).opacity(0.1),
                                    Color(red: 0.0, green: 1.0, blue: 0.5).opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
            .shadow(
                color: Color(red: 0.0, green: 1.0, blue: 1.0),
                radius: 15,
                x: 0,
                y: 0
            )

            // 赛博朋克系统信息
            VStack(spacing: 12) {
                // 配置文件路径显示
                HStack {
                    Text("◆")
                        .font(.system(size: 10, weight: .black, design: .monospaced))
                        .foregroundColor(Color(red: 1.0, green: 0.0, blue: 0.5))

                    Text("CONFIG_PATH:")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(Color(red: 0.0, green: 1.0, blue: 1.0))

                    Text("~/Library/Application Support/cccfg/configs.json")
                        .font(.system(size: 9, weight: .medium, design: .monospaced))
                        .foregroundColor(Color(red: 0.9, green: 0.9, blue: 0.9))
                        .lineLimit(1)
                        .truncationMode(.middle)

                    Spacer()
                }

                // 分组文件路径显示
                HStack {
                    Text("◆")
                        .font(.system(size: 10, weight: .black, design: .monospaced))
                        .foregroundColor(Color(red: 1.0, green: 0.0, blue: 0.5))

                    Text("GROUP_PATH:")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(Color(red: 0.0, green: 1.0, blue: 1.0))

                    Text("~/Library/Application Support/cccfg/groups.json")
                        .font(.system(size: 9, weight: .medium, design: .monospaced))
                        .foregroundColor(Color(red: 0.9, green: 0.9, blue: 0.9))
                        .lineLimit(1)
                        .truncationMode(.middle)

                    Spacer()
                }

                // 分隔线
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.0, green: 1.0, blue: 1.0).opacity(0.3),
                                Color(red: 0.8, green: 0.0, blue: 1.0).opacity(0.3),
                                Color(red: 0.0, green: 1.0, blue: 1.0).opacity(0.3)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 1)
                    .padding(.horizontal, 50)

                // 开发者信息
                HStack(spacing: 40) {
                    HStack(spacing: 8) {
                        Text("◆")
                            .font(.system(size: 10, weight: .black, design: .monospaced))
                            .foregroundColor(Color(red: 0.0, green: 1.0, blue: 0.5))

                        Text("DEVELOPER: WEIMING")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(Color(red: 0.9, green: 0.9, blue: 0.9))
                    }

                    HStack(spacing: 8) {
                        Text("◆")
                            .font(.system(size: 10, weight: .black, design: .monospaced))
                            .foregroundColor(Color(red: 0.0, green: 1.0, blue: 0.5))

                        Text("CONTACT: SWIMMING.XWM@GMAIL.COM")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(Color(red: 0.9, green: 0.9, blue: 0.9))
                    }

                    HStack(spacing: 8) {
                        Text("◆")
                            .font(.system(size: 10, weight: .black, design: .monospaced))
                            .foregroundColor(Color(red: 0.0, green: 1.0, blue: 0.5))

                        Text("VERSION: 1.1.4")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(Color(red: 0.0, green: 1.0, blue: 0.5))
                    }

                    Spacer()
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
        .frame(minWidth: 600, minHeight: 520)
        .onAppear {
            loadConfigs()
            loadGroups()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("LaunchDefaultConfig"))) { _ in
            // 启动默认配置
            if let defaultConfig = configs.first(where: { $0.isDefault }) {
                launcher.launchConfiguration(defaultConfig)
            } else if let firstConfig = configs.first {
                launcher.launchConfiguration(firstConfig)
            }
        }
        .sheet(item: $editingConfig) { config in
            ConfigEditView(config: config) { updatedConfig in
                updateConfig(updatedConfig)
            }
        }
        .sheet(isPresented: $showingAddConfig) {
            ConfigEditView { newConfig in
                addConfig(newConfig)
            }
        }
        .sheet(isPresented: $showingAddGroup) {
            SimpleGroupEditView { newGroup in
                addGroup(newGroup)
            }
        }
        .sheet(item: $editingGroup) { group in
            SimpleGroupEditView(group: group) { updatedGroup in
                updateGroup(updatedGroup)
            }
        }
        .alert("已复制", isPresented: $showCopiedAlert) {
            Button("确定", role: .cancel) { }
        } message: {
            Text("启动命令已复制到剪贴板")
        }
        .alert("确认删除分组", isPresented: $showingDeleteGroupAlert) {
            Button("取消", role: .cancel) { }
            Button("删除", role: .destructive) {
                if let group = groupToDelete {
                    // 删除分组前先将该分组的配置移到默认分组
                    for i in 0..<configs.count {
                        if configs[i].groupId == group.id {
                            configs[i].groupId = ConfigGroup.defaultGroupId
                        }
                    }
                    saveConfigs()
                    deleteGroup(group)
                    groupToDelete = nil
                }
            }
        } message: {
            if let group = groupToDelete {
                let configCount = configs.filter { $0.groupId == group.id }.count
                Text("确定要删除分组「\(group.name)」吗？\n\n该分组下的 \(configCount) 个配置将自动移到默认分组。")
            } else {
                Text("确定要删除这个分组吗？")
            }
        }
        }
    }

    private func loadConfigs() {
        configs = configManager.loadConfigs()
    }

    private func addConfig(_ config: Config) {
        var newConfig = config
        if let selectedGroupId = selectedGroupId {
            newConfig.groupId = selectedGroupId
        }
        configs.append(newConfig)
        saveConfigs()
    }

    private func updateConfig(_ config: Config) {
        if let index = configs.firstIndex(where: { $0.id == config.id }) {
            configs[index] = config
            saveConfigs()
        }
    }

    private func saveConfigs() {
        configManager.saveConfigs(configs)
    }

    private func addGroup(_ group: ConfigGroup) {
        groupManager.addGroup(group)
    }

    private func deleteGroup(_ group: ConfigGroup) {
        groupManager.deleteGroup(group)
    }

    private func updateGroup(_ group: ConfigGroup) {
        groupManager.updateGroup(group)
    }

    private func loadGroups() {
        let loadedGroups = groupManager.loadGroups()
        if !loadedGroups.isEmpty {
            groupManager.groups = loadedGroups
        }
    }
}

// 简化的分组编辑视图
struct SimpleGroupEditView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var groupName = ""
    @State private var selectedColor = "blue"
    let onSave: (ConfigGroup) -> Void
    private let editingGroup: ConfigGroup?
    private let isEditing: Bool

    private let availableColors = [
        ("blue", "蓝色", Color.blue),
        ("green", "绿色", Color.green),
        ("red", "红色", Color.red),
        ("orange", "橙色", Color.orange),
        ("purple", "紫色", Color.purple),
        ("pink", "粉色", Color.pink)
    ]

    init(group: ConfigGroup? = nil, onSave: @escaping (ConfigGroup) -> Void) {
        self.editingGroup = group
        self.isEditing = group != nil
        self.onSave = onSave
    }

    var body: some View {
        VStack(spacing: 20) {
            Text(isEditing ? "编辑分组" : "新建分组")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top)

            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("分组名称")
                        .font(.headline)
                    TextField("例如：工作项目", text: $groupName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disableAutocorrection(true)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("分组颜色")
                        .font(.headline)

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                        ForEach(availableColors, id: \.0) { colorValue, colorName, color in
                            Button(action: {
                                selectedColor = colorValue
                            }) {
                                HStack {
                                    Circle()
                                        .fill(color)
                                        .frame(width: 16, height: 16)
                                    Text(colorName)
                                        .font(.body)
                                    Spacer()
                                    if selectedColor == colorValue {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(color)
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(selectedColor == colorValue ? color.opacity(0.1) : Color.gray.opacity(0.05))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(selectedColor == colorValue ? color : Color.gray.opacity(0.3), lineWidth: selectedColor == colorValue ? 2 : 1)
                                )
                                .cornerRadius(8)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(20)

            Spacer()

            HStack(spacing: 20) {
                Button("取消") {
                    presentationMode.wrappedValue.dismiss()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)

                Button(isEditing ? "更新" : "创建") {
                    let newGroup: ConfigGroup
                    if let group = editingGroup {
                        // 编辑模式：保留原有ID和其他属性
                        newGroup = ConfigGroup(
                            id: group.id,
                            name: groupName,
                            color: selectedColor,
                            sortOrder: group.sortOrder
                        )
                    } else {
                        // 创建模式：生成新的ID
                        newGroup = ConfigGroup(name: groupName, color: selectedColor)
                    }
                    onSave(newGroup)
                    presentationMode.wrappedValue.dismiss()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(!groupName.isEmpty ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(groupName.isEmpty)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .frame(minWidth: 400, minHeight: 400)
        .onAppear {
            if let group = editingGroup {
                groupName = group.name
                selectedColor = group.color
            }
        }
    }
}

// 主应用
@main
struct cccfgApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .background(WindowAccessor())
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}

// 窗口访问器
struct WindowAccessor: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                WindowManager.shared.setMainWindow(window)
                window.delegate = context.coordinator
                window.standardWindowButton(.closeButton)?.isEnabled = true
            }
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            if let window = nsView.window, window.delegate == nil {
                window.delegate = context.coordinator
                WindowManager.shared.setMainWindow(window)
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, NSWindowDelegate {
        func windowShouldClose(_ sender: NSWindow) -> Bool {
            sender.orderOut(nil)
            return false
        }
    }
}