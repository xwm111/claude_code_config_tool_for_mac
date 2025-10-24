//
//  cccfg.swift - 完全可工作的演示版本
//  修复了macOS兼容性问题
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

    func requestFocus() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    func toggleWindowVisibility() {
        DispatchQueue.main.async {
            guard let window = self.mainWindow ?? NSApp.keyWindow else { return }

            if window.isVisible {
                window.orderOut(nil)
            } else {
                window.makeKeyAndOrderFront(nil)
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }

    func hideWindow() {
        DispatchQueue.main.async {
            guard let window = self.mainWindow ?? NSApp.keyWindow else { return }
            window.orderOut(nil)
        }
    }

    func showWindow() {
        DispatchQueue.main.async {
            guard let window = self.mainWindow ?? NSApp.keyWindow else { return }
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}

// 应用程序代理
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    private let configManager = ConfigManager.shared

    func applicationDidFinishLaunching(_ notification: Notification) {
        // 设置 PATH 环境变量以包含 Node.js 和 Claude CLI 路径
        setupEnvironment()

        // 设置应用图标
        setupDockIcon()

        // 设置系统托盘
        setupStatusItem()

        // 确保应用显示在Dock中
        NSApp.setActivationPolicy(.regular)

        print("🚀 cccfg 应用启动完成")
        print("📁 配置文件位置: \(configManager.getConfigURL().path)")
    }

    private func setupEnvironment() {
        // 获取当前 PATH
        let currentPath = ProcessInfo.processInfo.environment["PATH"] ?? ""

        // 添加 Node.js 路径到 PATH
        let nodePath = "/Users/weimingxu/.nvm/versions/node/v22.14.0/bin"
        let newPath = "\(nodePath):\(currentPath)"

        // 设置环境变量
        setenv("PATH", newPath, 1)

        print("🔧 环境变量设置完成")
        print("   PATH: \(newPath)")
        print("   Node.js 路径已添加: \(nodePath)")
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            WindowManager.shared.showWindow()
        }
        return true
    }

    func applicationWillTerminate(_ notification: Notification) {
        // 清理系统托盘
        if let statusItem = statusItem {
            NSStatusBar.system.removeStatusItem(statusItem)
        }
    }

    private func setupDockIcon() {
        // 创建一个简单的图标
        let iconSize = NSSize(width: 512, height: 512)
        let image = NSImage(size: iconSize)

        image.lockFocus()

        // 绘制背景
        let rect = NSRect(origin: .zero, size: iconSize)
        NSColor.controlAccentColor.setFill()
        NSBezierPath(roundedRect: rect, xRadius: 64, yRadius: 64).fill()

        // 绘制齿轮图标
        let gearRect = NSRect(x: iconSize.width * 0.25, y: iconSize.height * 0.25,
                             width: iconSize.width * 0.5, height: iconSize.height * 0.5)
        NSColor.white.setFill()

        // 简单的齿轮形状
        let path = NSBezierPath()
        let center = NSPoint(x: iconSize.width * 0.5, y: iconSize.height * 0.5)
        let outerRadius: CGFloat = min(iconSize.width, iconSize.height) * 0.25
        let innerRadius: CGFloat = outerRadius * 0.6

        // 绘制齿轮的外圈
        for i in 0..<8 {
            let angle = Double(i) * .pi / 4
            let outerPoint = NSPoint(
                x: center.x + cos(angle) * outerRadius,
                y: center.y + sin(angle) * outerRadius
            )
            let innerPoint = NSPoint(
                x: center.x + cos(angle + .pi / 8) * innerRadius,
                y: center.y + sin(angle + .pi / 8) * innerRadius
            )

            if i == 0 {
                path.move(to: outerPoint)
            } else {
                path.line(to: outerPoint)
            }
            path.line(to: innerPoint)
        }
        path.close()
        path.fill()

        // 中心圆
        let centerCircle = NSBezierPath(ovalIn: NSRect(
            x: center.x - innerRadius * 0.5,
            y: center.y - innerRadius * 0.5,
            width: innerRadius,
            height: innerRadius
        ))
        NSColor.controlAccentColor.setFill()
        centerCircle.fill()

        image.unlockFocus()

        NSApplication.shared.applicationIconImage = image
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem?.button {
            // 创建一个简单的状态栏图标
            let iconSize = NSSize(width: 18, height: 18)
            let statusImage = NSImage(size: iconSize)

            statusImage.lockFocus()
            let rect = NSRect(origin: .zero, size: iconSize)
            NSColor.controlAccentColor.setFill()
            NSBezierPath(roundedRect: rect, xRadius: 4, yRadius: 4).fill()

            // 小齿轮
            NSColor.white.setFill()
            let gearPath = NSBezierPath()
            let center = NSPoint(x: iconSize.width * 0.5, y: iconSize.height * 0.5)
            let radius: CGFloat = min(iconSize.width, iconSize.height) * 0.3

            for i in 0..<6 {
                let angle = Double(i) * .pi / 3
                let point = NSPoint(
                    x: center.x + cos(angle) * radius,
                    y: center.y + sin(angle) * radius
                )
                if i == 0 {
                    gearPath.move(to: point)
                } else {
                    gearPath.line(to: point)
                }
            }
            gearPath.close()
            gearPath.fill()

            statusImage.unlockFocus()

            button.image = statusImage
            button.action = #selector(statusItemClicked)
            button.target = self
        }

        // 创建菜单
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "显示窗口", action: #selector(showWindow), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "隐藏窗口", action: #selector(hideWindow), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "退出", action: #selector(quitApp), keyEquivalent: "q"))

        statusItem?.menu = menu
    }

    @objc private func statusItemClicked() {
        WindowManager.shared.toggleWindowVisibility()
    }

    @objc private func showWindow() {
        WindowManager.shared.showWindow()
    }

    @objc private func hideWindow() {
        WindowManager.shared.hideWindow()
    }

    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}

// iTerm2和Claude CLI启动器
class CLILauncher: ObservableObject {
    @Published var isLaunching = false
    @Published var launchStatus = ""
    @Published var launchError: String?
    @Published var showErrorAlert = false
    @Published var errorMessage = ""

    func launchEnvironment(with config: Config) async {
        await MainActor.run {
            isLaunching = true
            launchStatus = "正在启动环境..."
            launchError = nil
            showErrorAlert = false
        }

        do {
            // 步骤1：检查依赖
            await updateStatus("检查系统依赖...")
            try await checkDependencies()

            // 步骤2：启动iTerm2
            await updateStatus("启动iTerm2...")
            try await launchiTerm2(with: config)

            // 步骤3：配置Claude CLI环境
            await updateStatus("配置Claude CLI环境...")
            try await setupClaudeEnvironment(with: config)

            // 步骤4：启动Claude CLI
            await updateStatus("启动Claude Code CLI...")
            try await launchClaudeCLI(with: config)

            await MainActor.run {
                launchStatus = "✅ 启动成功！"
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.isLaunching = false
                    self.launchStatus = ""
                }
            }

        } catch {
            await MainActor.run {
                let errorDetails = """
配置名称: \(config.name)
错误信息: \(error.localizedDescription)
时间: \(Date())
配置详情:
- API URL: \(config.apiUrl)
- 工作目录: \(config.workingDirectory)
- API Key: \(String(config.apiKey.prefix(12)))****
"""
                errorMessage = errorDetails
                showErrorAlert = true
                launchError = error.localizedDescription
                isLaunching = false
            }
        }
    }

    private func updateStatus(_ status: String) async {
        await MainActor.run {
            launchStatus = status
        }
    }

    private func checkDependencies() async throws {
        // 检查iTerm2是否安装
        let iTermPath = "/Applications/iTerm.app"
        guard FileManager.default.fileExists(atPath: iTermPath) else {
            throw LaunchError.iTerm2NotFound
        }

        // 检查Claude CLI是否安装 - 使用 PATH 环境变量
        print("🔍 开始检查 Claude CLI...")

        // 使用 bash 来执行 claude --version，这样会使用 PATH 环境变量
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/bash")
        task.arguments = ["-l", "-c", "claude --version"]
        task.standardOutput = Pipe()
        task.standardError = Pipe()

        do {
            try task.run()
            task.waitUntilExit()

            let data = (task.standardOutput as? Pipe)?.fileHandleForReading.readDataToEndOfFile() ?? Data()
            let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

            if task.terminationStatus == 0 && !output.isEmpty {
                print("✅ Claude CLI 检测成功")
                print("   版本: \(output)")
            } else {
                print("❌ Claude CLI 执行失败，退出码: \(task.terminationStatus)")
                throw LaunchError.claudeCLINotFound
            }
        } catch {
            print("❌ Claude CLI 检测失败: \(error)")
            throw LaunchError.claudeCLINotFound
        }
    }

    private func launchiTerm2(with config: Config) async throws {
        // 首先尝试使用 AppleScript 方法
        do {
            let script = createiTerm2Script(with: config)

            // 调试：打印生成的脚本
            print("=== Generated iTerm2 Script ===")
            print(script)
            print("=== End Script ===")

            let appleScript = NSAppleScript(source: script)

            var errorDict: NSDictionary?
            let result = appleScript?.executeAndReturnError(&errorDict)

            if let error = errorDict {
                throw LaunchError.appleScriptFailed(error.description as? String ?? "Unknown AppleScript error")
            }

            // 等待一小段时间确保iTerm2已启动
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1秒
        } catch {
            // 如果 AppleScript 失败，使用备用方法
            print("AppleScript 方法失败，尝试备用启动方法...")
            try await launchiTerm2Alternative(with: config)
        }
    }

    private func launchiTerm2Alternative(with config: Config) async throws {
        // 完全不使用 AppleScript 的备用方法
        print("使用完全备用方法启动...")

        // 1. 创建启动脚本
        let tempScriptPath = "/tmp/claude_launch_\(UUID().uuidString).sh"
        var scriptContent = "#!/bin/bash\n"
        scriptContent += "# Claude Code 启动脚本\n"
        scriptContent += "# 自动生成的临时脚本\n\n"

        if !config.workingDirectory.isEmpty {
            scriptContent += "cd \"\(config.workingDirectory)\"\n"
        }

        scriptContent += "echo '🚀 启动Claude Code CLI...'\n"
        scriptContent += "echo '配置: \(config.name)'\n"
        scriptContent += "echo 'API URL: \(config.apiUrl)'\n"
        scriptContent += "echo '工作目录: \(config.workingDirectory)'\n"
        scriptContent += "echo ''\n"
        scriptContent += "export ANTHROPIC_AUTH_TOKEN=\"\(config.apiKey)\"\n"
        scriptContent += "export ANTHROPIC_BASE_URL=\"\(config.apiUrl)\"\n"

        // 检查 iTerm 是否存在，如果存在则在新窗口中打开
        scriptContent += "if command -v iTerm2 &> /dev/null; then\n"
        scriptContent += "    # 使用 iTerm2 的 open 命令在新窗口中打开\n"
        scriptContent += "    osascript -e 'tell application \"iTerm\" to create window with default profile' 2>/dev/null || {\n"
        scriptContent += "        open -a iTerm2\n"
        scriptContent += "        sleep 2\n"
        scriptContent += "    }\n"
        scriptContent += "    sleep 1\n"
        scriptContent += "    # 在新窗口中执行命令\n"
        scriptContent += "    osascript -e 'tell application \"iTerm\" to tell current session of current window to write text \"exec bash\"' 2>/dev/null || true\n"
        scriptContent += "    sleep 0.5\n"
        scriptContent += "    osascript -e 'tell application \"iTerm\" to tell current session of current window to write text \"clear\"' 2>/dev/null || true\n"
        scriptContent += "    sleep 0.5\n"
        scriptContent += "    osascript -e 'tell application \"iTerm\" to tell current session of current window to write text \"echo \\\"🚀 Claude Code CLI 已就绪\\\"\"' 2>/dev/null || true\n"
        scriptContent += "else\n"
        scriptContent += "    # 回退到 Terminal\n"
        scriptContent += "    open -a Terminal\n"
        scriptContent += "    sleep 2\n"
        scriptContent += "fi\n"
        scriptContent += "\n"
        scriptContent += "exec claude\n"

        try scriptContent.write(toFile: tempScriptPath, atomically: true, encoding: .utf8)
        try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: tempScriptPath)

        // 2. 启动 iTerm2（如果存在）
        let iTermPath = "/Applications/iTerm.app"
        let iTerm2Path = "/Applications/iTerm2.app"

        if FileManager.default.fileExists(atPath: iTerm2Path) {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
            process.arguments = ["-a", "iTerm2"]
            try process.run()
            process.waitUntilExit()
        } else if FileManager.default.fileExists(atPath: iTermPath) {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
            process.arguments = ["-a", "iTerm"]
            try process.run()
            process.waitUntilExit()
        } else {
            // 如果没有 iTerm，直接在当前终端启动
            print("未找到 iTerm，在当前环境中启动...")

            // 设置环境变量并启动 Claude CLI
            let claudeProcess = Process()
            claudeProcess.executableURL = URL(fileURLWithPath: "/bin/bash")
            claudeProcess.arguments = ["-c", "export PATH=\"/Users/weimingxu/.nvm/versions/node/v22.14.0/bin:$PATH\" && export ANTHROPIC_AUTH_TOKEN=\"\(config.apiKey)\" && export ANTHROPIC_BASE_URL=\"\(config.apiUrl)\" && \(config.workingDirectory.isEmpty ? "" : "cd \"\(config.workingDirectory)\" && ")claude"]

            // 设置当前工作目录
            if !config.workingDirectory.isEmpty {
                claudeProcess.currentDirectoryURL = URL(fileURLWithPath: config.workingDirectory)
            }

            try claudeProcess.run()
            return
        }

        // 3. 等待 iTerm 启动
        try await Task.sleep(nanoseconds: 2_000_000_000)

        // 4. 使用系统命令在新窗口中执行脚本
        let shellProcess = Process()
        shellProcess.executableURL = URL(fileURLWithPath: "/bin/bash")
        shellProcess.arguments = ["-c", tempScriptPath]

        if !config.workingDirectory.isEmpty {
            shellProcess.currentDirectoryURL = URL(fileURLWithPath: config.workingDirectory)
        }

        try shellProcess.run()

        // 5. 清理临时脚本（延迟清理）
        DispatchQueue.main.asyncAfter(deadline: .now() + 60) {
            try? FileManager.default.removeItem(atPath: tempScriptPath)
        }
    }

    private func setupClaudeEnvironment(with config: Config) async throws {
        // 设置环境变量
        let env = ProcessInfo.processInfo.environment

        // 创建临时脚本来设置环境
        let tempScriptPath = "/tmp/claude_env_setup.sh"
        var scriptContent = "#!/bin/bash\n"
        // 清除可能冲突的环境变量（不再使用export方式）
        // scriptContent += "unset ANTHROPIC_BASE_URL\n"
        // scriptContent += "unset ANTHROPIC_AUTH_TOKEN\n"
        // 直接使用命令行前缀方式启动
        let claudeCommand = "export PATH=\"/Users/weimingxu/.nvm/versions/node/v22.14.0/bin:$PATH\" && ANTHROPIC_AUTH_TOKEN=\"\(config.apiKey)\" ANTHROPIC_BASE_URL=\"\(config.apiUrl)\" claude"

        if !config.workingDirectory.isEmpty {
            scriptContent += "cd \"\(config.workingDirectory)\"\n"
        }

        // 添加启动Claude CLI的命令
        scriptContent += "echo '🚀 启动Claude Code CLI...'\n"
        scriptContent += "echo '配置: \(config.name)'\n"
        scriptContent += "echo 'API URL: \(config.apiUrl)'\n"
        scriptContent += "echo '工作目录: \(config.workingDirectory)'\n"
        scriptContent += "echo ''\n"
        scriptContent += claudeCommand + "\n"

        try scriptContent.write(toFile: tempScriptPath, atomically: true, encoding: .utf8)
        try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: tempScriptPath)
    }

    private func launchClaudeCLI(with config: Config) async throws {
        let script = createClaudeCLIScript(with: config)

        // 调试：打印生成的Claude CLI脚本
        print("=== Generated Claude CLI Script ===")
        print(script)
        print("=== End Claude CLI Script ===")

        let appleScript = NSAppleScript(source: script)

        var errorDict: NSDictionary?
        let result = appleScript?.executeAndReturnError(&errorDict)

        if let error = errorDict {
            throw LaunchError.appleScriptFailed(error.description as? String ?? "Unknown AppleScript error")
        }
    }

    private func createiTerm2Script(with config: Config) -> String {
        var script = "tell application \"iTerm\"\n"
        script += "    activate\n"
        script += "\n"
        script += "    -- 创建新的窗口\n"
        script += "    create window with default profile\n"
        script += "\n"
        script += "    -- 获取当前会话\n"
        script += "    tell current session of current window\n"

        if !config.workingDirectory.isEmpty {
            let escapedDir = config.workingDirectory.replacingOccurrences(of: "\"", with: "\\\"")
            script += "        write text \"cd '\(escapedDir)'\"\n"
        }

        script += "    end tell\n"
        script += "end tell"

        return script
    }

    private func createClaudeCLIScript(with config: Config) -> String {
        // 转义特殊字符以避免AppleScript语法错误
        let escapedName = config.name.replacingOccurrences(of: "'", with: "'\\''")
        let escapedUrl = config.apiUrl.replacingOccurrences(of: "'", with: "'\\''")
        let escapedDir = config.workingDirectory.replacingOccurrences(of: "'", with: "'\\''")
        let escapedKey = config.apiKey.replacingOccurrences(of: "'", with: "'\\''")
        let escapedModel = config.modelName.replacingOccurrences(of: "'", with: "'\\''")

        var script = "tell application \"iTerm\"\n"
        script += "    tell current session of current window\n"

        script += "        -- 启动Claude CLI\n"
        script += "        write text \"echo '🚀 启动Claude Code CLI...'\"\n"
        script += "        write text \"echo '配置: " + escapedName + "'\"\n"
        script += "        write text \"echo 'API URL: " + escapedUrl + "'\"\n"
        script += "        write text \"echo '工作目录: " + escapedDir + "'\"\n"

        if !config.modelName.isEmpty {
            script += "        write text \"echo '模型: " + escapedModel + "'\"\n"
        }

        script += "        write text \"\"\n"
        script += "        write text \"export PATH='/Users/weimingxu/.nvm/versions/node/v22.14.0/bin:$PATH' && ANTHROPIC_AUTH_TOKEN='" + escapedKey + "' ANTHROPIC_BASE_URL='" + escapedUrl + "' claude\"\n"

        // 等待 Claude Code 启动后，自动设置模型
        if !config.modelName.isEmpty {
            script += "        delay 2\n"  // 等待2秒让 Claude Code 完全启动
            script += "        write text \"/model " + escapedModel + "\"\n"
        }

        script += "    end tell\n"
        script += "end tell"

        return script
    }
}

// 启动错误类型
enum LaunchError: LocalizedError {
    case iTerm2NotFound
    case claudeCLINotFound
    case appleScriptFailed(String)

    var errorDescription: String? {
        switch self {
        case .iTerm2NotFound:
            return "iTerm2未安装。请从 https://iterm2.com 下载并安装iTerm2。"
        case .claudeCLINotFound:
            return "Claude CLI未安装。请确保Claude CLI已安装并在PATH中。"
        case .appleScriptFailed(let message):
            return "AppleScript执行失败: \(message)"
        }
    }
}

// 配置管理器 - 负责持久化存储
class ConfigManager: ObservableObject {
    static let shared = ConfigManager()

    private let configURL: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private init() {
        // 获取应用支持目录
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDir = appSupport.appendingPathComponent("cccfg")

        // 创建目录（如果不存在）
        try? FileManager.default.createDirectory(at: appDir, withIntermediateDirectories: true)

        configURL = appDir.appendingPathComponent("configs.json")
    }

    func saveConfigs(_ configs: [Config]) {
        do {
            let data = try encoder.encode(configs)
            try data.write(to: configURL)
            print("✅ 配置已保存到: \(configURL.path)")
        } catch {
            print("❌ 保存配置失败: \(error.localizedDescription)")
        }
    }

    func loadConfigs() -> [Config] {
        guard FileManager.default.fileExists(atPath: configURL.path) else {
            print("📝 配置文件不存在，返回空配置列表")
            return []
        }

        do {
            let data = try Data(contentsOf: configURL)
            let configs = try decoder.decode([Config].self, from: data)
            print("✅ 成功加载 \(configs.count) 个配置")
            return configs
        } catch {
            print("❌ 加载配置失败: \(error.localizedDescription)")
            return []
        }
    }

    func deleteConfigs() {
        do {
            try FileManager.default.removeItem(at: configURL)
            print("✅ 配置文件已删除")
        } catch {
            print("❌ 删除配置文件失败: \(error.localizedDescription)")
        }
    }

    func getConfigURL() -> URL {
        return configURL
    }
}

// 配置模型
struct Config: Identifiable, Codable {
    var id = UUID()
    var name: String = ""
    var apiUrl: String = "https://api.anthropic.com"
    var apiKey: String = ""
    var workingDirectory: String = ""
    var modelName: String = ""  // 默认为空，兼容旧配置
    var isDefault: Bool = false

    var isValid: Bool {
        !name.isEmpty && !apiUrl.isEmpty && apiUrl.hasPrefix("http") && !apiKey.isEmpty && !workingDirectory.isEmpty
    }

    // 自定义解码，兼容没有 modelName 字段的旧配置
    enum CodingKeys: String, CodingKey {
        case id, name, apiUrl, apiKey, workingDirectory, modelName, isDefault
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        apiUrl = try container.decode(String.self, forKey: .apiUrl)
        apiKey = try container.decode(String.self, forKey: .apiKey)
        workingDirectory = try container.decode(String.self, forKey: .workingDirectory)
        // 兼容旧配置：如果没有 modelName 字段，使用空字符串
        modelName = (try? container.decode(String.self, forKey: .modelName)) ?? ""
        isDefault = try container.decode(Bool.self, forKey: .isDefault)
    }

    // 默认初始化器
    init() {
        self.id = UUID()
        self.name = ""
        self.apiUrl = "https://api.anthropic.com"
        self.apiKey = ""
        self.workingDirectory = ""
        self.modelName = ""
        self.isDefault = false
    }
}

// 主应用
@main
struct cccfgApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    WindowManager.shared.activateWindow()
                }
                .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
                    WindowManager.shared.activateWindow()
                }
                .background(WindowAccessor())
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .handlesExternalEvents(matching: Set(arrayLiteral: "main"))  // 确保只有一个窗口
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("退出") {
                    NSApplication.shared.terminate(nil)
                }
                .keyboardShortcut("q", modifiers: .command)
            }
        }
    }
}

// 窗口访问器 - 用于获取窗口引用并设置关闭行为
struct WindowAccessor: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                WindowManager.shared.setMainWindow(window)

                // 设置窗口代理以拦截关闭事件
                window.delegate = context.coordinator

                // 确保窗口可以关闭按钮（但实际会被拦截）
                window.standardWindowButton(.closeButton)?.isEnabled = true
            }
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        // 确保窗口代理始终设置
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
            // 拦截关闭事件，隐藏窗口而不是销毁
            sender.orderOut(nil)
            return false  // 返回 false 阻止窗口销毁
        }
    }
}

// 主视图
struct ContentView: View {
    @StateObject private var configManager = ConfigManager.shared
    @State private var configs: [Config] = []
    @State private var showingAddConfig = false
    @State private var editingConfig: Config?
    @State private var showCopiedAlert = false

    var body: some View {
        VStack(spacing: 20) {
            // 标题区域
            VStack(spacing: 8) {
                Text("CCC Config")
                    .font(.system(size: 32, weight: .bold))

                Text("Claude Code CLI 配置管理工具")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 30)

            // 配置文件地址显示区域 - 改进版
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "externaldrive.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 14))
                    Text("配置文件保存位置")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                }

                HStack(spacing: 8) {
                    Text(configManager.getConfigURL().path)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .textSelection(.enabled)

                    Spacer()

                    // 复制按钮
                    Button(action: {
                        let pasteboard = NSPasteboard.general
                        pasteboard.clearContents()
                        pasteboard.setString(configManager.getConfigURL().path, forType: .string)
                        showCopiedAlert = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 10))
                            Text("复制")
                                .font(.system(size: 11))
                        }
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)

                    // 在Finder中显示按钮
                    Button(action: {
                        NSWorkspace.shared.selectFile(configManager.getConfigURL().path, inFileViewerRootedAtPath: "")
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "folder")
                                .font(.system(size: 10))
                            Text("显示")
                                .font(.system(size: 11))
                        }
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                )
                .cornerRadius(8)
            }
            .padding(.horizontal, 20)
            .alert("已复制", isPresented: $showCopiedAlert) {
                Button("好的", role: .cancel) { }
            } message: {
                Text("配置文件路径已复制到剪贴板")
            }


            // 配置列表区域
            if configs.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "gear.badge.plus")
                        .font(.system(size: 64))
                        .foregroundColor(.blue)

                    Text("还没有配置")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("点击下方按钮创建您的第一个配置")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(configs) { config in
                            ConfigRowView(
                                config: config,
                                onDelete: { configToDelete in
                                    deleteConfig(configToDelete)
                                },
                                onEdit: { configToEdit in
                                    editingConfig = configToEdit
                                },
                                onLaunch: { configToLaunch in
                                    // 启动配置的处理已在ConfigRowView内部完成
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            // 添加配置按钮
            Button(action: {
                showingAddConfig = true
            }) {
                HStack {
                    Image(systemName: "plus")
                    Text("添加配置")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(10)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .frame(minWidth: 600, minHeight: 500)
        .onAppear {
            loadConfigs()
        }
        .sheet(item: $editingConfig) { config in
            ConfigEditView(config: config) { updatedConfig in
                updateConfig(updatedConfig)
            }
            .onAppear {
                WindowManager.shared.requestFocus()
            }
        }
        .sheet(isPresented: $showingAddConfig) {
            ConfigEditView { newConfig in
                addConfig(newConfig)
            }
            .onAppear {
                WindowManager.shared.requestFocus()
            }
        }
    }

    // MARK: - 配置管理方法
    private func loadConfigs() {
        configs = configManager.loadConfigs()
    }

    private func addConfig(_ config: Config) {
        configs.append(config)
        saveConfigs()
    }

    private func saveConfigs() {
        configManager.saveConfigs(configs)
    }

    private func deleteConfig(_ config: Config) {
        configs.removeAll { $0.id == config.id }
        saveConfigs()
    }

    private func updateConfig(_ config: Config) {
        if let index = configs.firstIndex(where: { $0.id == config.id }) {
            configs[index] = config
            saveConfigs()
        }
    }
}

// 配置行视图
struct ConfigRowView: View {
    let config: Config
    let onDelete: (Config) -> Void
    let onEdit: (Config) -> Void
    let onLaunch: (Config) -> Void

    @StateObject private var launcher = CLILauncher()
    @State private var showingDeleteAlert = false

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 12) {
                // 配置名称和默认标签
                HStack {
                    Text(config.name)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    if config.isDefault {
                        Text("默认配置")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green)
                            .cornerRadius(6)
                    }
                }

                // 环境变量信息
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("🌐 ANTHROPIC_BASE_URL:")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        Text(config.apiUrl)
                            .font(.caption)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        Spacer()
                    }

                    if !config.apiKey.isEmpty {
                        HStack {
                            Text("🔑 ANTHROPIC_AUTH_TOKEN:")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            Text("\(String(config.apiKey.prefix(12)))****")
                                .font(.caption)
                                .foregroundColor(.primary)
                                .monospaced()
                            Spacer()
                        }
                    }

                    if !config.workingDirectory.isEmpty {
                        HStack {
                            Text("📁 工作目录:")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            Text(config.workingDirectory)
                                .font(.caption)
                                .foregroundColor(.primary)
                                .lineLimit(1)
                            Spacer()
                        }
                    }

                    if !config.modelName.isEmpty {
                        HStack {
                            Text("🤖 模型:")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            Text(config.modelName)
                                .font(.caption)
                                .foregroundColor(.blue)
                                .monospaced()
                            Spacer()
                        }
                    }
                }
            }

            Spacer()

            HStack(spacing: 16) {
                // 启动状态和按钮
                if launcher.isLaunching {
                    ProgressView()
                        .scaleEffect(1.2)
                        .controlSize(.large)
                } else {
                    // 启动按钮 - 更大更显眼
                    Button(action: {
                        Task {
                            await launcher.launchEnvironment(with: config)
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "play.fill")
                                .font(.title3)
                                .foregroundColor(.white)
                            Text("启动")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            config.isValid ? LinearGradient(
                                colors: [Color.green.opacity(0.9), Color.green],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) : LinearGradient(
                                colors: [Color.gray.opacity(0.6), Color.gray.opacity(0.4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: config.isValid ? Color.green.opacity(0.3) : Color.clear, radius: 4, x: 0, y: 2)
                    }
                    .buttonStyle(.plain)
                    .help("启动Claude CLI")
                    .disabled(!config.isValid || launcher.isLaunching)
                    .scaleEffect(launcher.isLaunching ? 0.95 : 1.0)
                    .animation(.easeInOut(duration: 0.1), value: launcher.isLaunching)
                }

                // 状态图标 - 调整大小和颜色
                Image(systemName: config.isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(config.isValid ? .green : .red)

                Text(config.isValid ? "有效" : "无效")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(config.isValid ? .green : .red)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(config.isValid ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                    .cornerRadius(6)

                Spacer()

                // 删除按钮
                Button(action: {
                    showingDeleteAlert = true
                }) {
                    Image(systemName: "trash")
                        .font(.title3)
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
                .help("删除配置")
            }
        }
        .padding(20)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .onTapGesture {
            onEdit(config)
        }
        .overlay(
            // 启动状态和错误显示
            VStack {
                if !launcher.launchStatus.isEmpty {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text(launcher.launchStatus)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(6)
                    .padding(.top, 8)
                }

                if let error = launcher.launchError {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(6)
                    .padding(.top, 8)
                }

                Spacer()
            }
            .opacity(launcher.isLaunching || launcher.launchError != nil ? 1 : 0),
            alignment: .topLeading
        )
        .alert("删除配置", isPresented: $showingDeleteAlert) {
            Button("取消", role: .cancel) {
                // 不执行任何操作
            }
            Button("删除", role: .destructive) {
                onDelete(config)
            }
        } message: {
            Text("确定要删除配置 \"\(config.name)\" 吗？此操作无法撤销。")
        }
        .alert("启动错误", isPresented: $launcher.showErrorAlert) {
            Button("确定") {
                launcher.showErrorAlert = false
            }
            Button("复制错误信息") {
                let pasteboard = NSPasteboard.general
                pasteboard.clearContents()
                pasteboard.setString(launcher.errorMessage, forType: .string)
            }
        } message: {
            Text(launcher.errorMessage)
        }
    }
}

// 配置编辑视图
struct ConfigEditView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var config: Config
    @FocusState private var isNameFieldFocused: Bool
    let onSave: (Config) -> Void
    let isEditing: Bool

    init(config: Config? = nil, onSave: @escaping (Config) -> Void) {
        self.config = config ?? Config()
        self.onSave = onSave
        self.isEditing = config != nil
    }

    var body: some View {
        VStack(spacing: 20) {
            // 标题
            Text(isEditing ? "编辑配置" : "添加新配置")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        isNameFieldFocused = true
                        WindowManager.shared.activateWindow()
                    }
                }

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 配置名称
                    VStack(alignment: .leading, spacing: 8) {
                        Text("配置名称")
                            .font(.headline)
                            .foregroundColor(.primary)
                        TextField("例如：工作项目", text: $config.name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.body)
                            .focused($isNameFieldFocused)
                    }

                    // API URL
                    VStack(alignment: .leading, spacing: 8) {
                        Text("ANTHROPIC_BASE_URL")
                            .font(.headline)
                            .foregroundColor(.primary)
                        TextField("https://api.anthropic.com", text: $config.apiUrl)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.body)
                    }

                    // API Key
                    VStack(alignment: .leading, spacing: 8) {
                        Text("ANTHROPIC_AUTH_TOKEN")
                            .font(.headline)
                            .foregroundColor(.primary)
                        SecureField("sk-ant-api03-...", text: $config.apiKey)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.body)
                    }

                    // 工作目录
                    VStack(alignment: .leading, spacing: 8) {
                        Text("工作目录")
                            .font(.headline)
                            .foregroundColor(.primary)
                        HStack {
                            TextField("/path/to/your/project", text: $config.workingDirectory)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.body)

                            Button("浏览") {
                                selectWorkingDirectory()
                            }
                            .buttonStyle(.bordered)
                        }
                    }

                    // 模型名称
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("模型名称")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text("(可选)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        TextField("例如: claude-sonnet-4-5-20250929", text: $config.modelName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.body)
                        Text("启动后将自动执行 /model 命令设置此模型，留空则不自动设置")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    // 默认配置
                    Toggle("设为默认配置", isOn: $config.isDefault)
                        .font(.headline)
                        .foregroundColor(.primary)

                    // 验证状态
                    VStack(alignment: .leading, spacing: 10) {
                        Text("验证状态")
                            .font(.headline)
                            .foregroundColor(.primary)

                        HStack {
                            Image(systemName: config.isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(config.isValid ? .green : .red)
                                .font(.title2)

                            Text(config.isValid ? "配置有效" : "配置无效")
                                .font(.body)
                                .foregroundColor(config.isValid ? .green : .red)
                        }

                        if !config.isValid {
                            VStack(alignment: .leading, spacing: 5) {
                                if config.name.isEmpty {
                                    Text("• 配置名称不能为空")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                                if config.apiUrl.isEmpty || !config.apiUrl.hasPrefix("http") {
                                    Text("• ANTHROPIC_BASE_URL必须以http开头且不为空")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                                if config.apiKey.isEmpty {
                                    Text("• ANTHROPIC_AUTH_TOKEN不能为空")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                                if config.workingDirectory.isEmpty {
                                    Text("• 工作目录不能为空")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding(20)
            }

            Spacer()

            // 按钮区域
            HStack(spacing: 20) {
                Button("取消") {
                    presentationMode.wrappedValue.dismiss()
                }
                .font(.headline)
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)

                Button(isEditing ? "更新" : "保存") {
                    onSave(config)
                    presentationMode.wrappedValue.dismiss()
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(config.isValid ? Color.blue : Color.gray)
                .cornerRadius(10)
                .disabled(!config.isValid)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
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