import Foundation

// 测试应用程序中的依赖检查逻辑
func testClaudeDetection() {
    print("=== 测试应用程序的 Claude CLI 检测逻辑 ===")

    let claudePath = "/Users/weimingxu/.nvm/versions/node/v22.14.0/bin/claude"

    // 先尝试直接执行，这是最可靠的检查方法
    let task = Process()
    task.executableURL = URL(fileURLWithPath: claudePath)
    task.arguments = ["--version"]
    task.standardOutput = Pipe()
    task.standardError = Pipe()

    do {
        try task.run()
        task.waitUntilExit()

        if task.terminationStatus != 0 {
            print("❌ Claude CLI 执行失败，退出码: \(task.terminationStatus)")
            return
        }

        // 如果执行成功，说明Claude CLI存在且可用
        print("✅ Claude CLI 检测成功: \(claudePath)")

        // 读取输出版本信息
        let data = (task.standardOutput as? Pipe)?.fileHandleForReading.readDataToEndOfFile() ?? Data()
        let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !output.isEmpty {
            print("   版本: \(output)")
        }

    } catch {
        print("❌ 执行 Claude CLI 时发生错误: \(error)")

        // 如果直接执行失败，尝试FileManager检查作为备用
        if !FileManager.default.fileExists(atPath: claudePath) {
            print("❌ Claude CLI 文件不存在: \(claudePath)")
        } else {
            print("❌ Claude CLI 存在但无法执行: \(claudePath)")
        }
    }
}

// 运行测试
testClaudeDetection()