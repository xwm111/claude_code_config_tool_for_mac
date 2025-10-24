# Research Findings: 离线使用能力

**Date**: 2025-10-23
**Feature**: 离线使用能力特性
**Phase**: 0 - Research & Analysis

## Architecture Decisions

### 1. 离线优先架构 (Offline-First Architecture)

**Decision**: 采用本地优先 (Local-First) 架构模式，所有数据存储在本地，无需网络同步。

**Rationale**:
- 确保完全离线运行能力
- 简化数据管理复杂度
- 提高响应速度和用户体验
- 降低开发和维护成本

**Alternatives considered**:
- 混合架构（本地+云端同步）：需要网络依赖，与离线目标冲突
- 纯云端架构：完全不符合离线使用需求

### 2. 数据存储策略

**Decision**: 使用 Core Data 作为主要数据存储，Keychain 存储敏感信息，本地文件系统处理 JSON 导入导出。

**Rationale**:
- Core Data 提供高性能的本地数据管理
- Keychain 确保敏感信息安全存储
- JSON 格式确保跨平台兼容性
- 内置资源 Bundle 避免网络依赖

**Alternatives considered**:
- SQLite 直接访问：增加开发复杂度，缺乏 Core Data 的优化
- plist 文件存储：性能较差，不适合大量数据
- 自定义二进制格式：开发成本高，维护困难

### 3. 资源管理策略

**Decision**: 所有帮助文档、模板和错误信息资源内置在应用程序 Bundle 中，运行时从本地加载。

**Rationale**:
- 确保完全离线可用性
- 避免资源更新依赖网络
- 提高资源加载速度
- 简化版本管理和部署

**Alternatives considered**:
- 动态下载资源：需要网络连接，违反离线原则
- 用户手动导入：用户体验差，操作复杂

### 4. 错误处理策略

**Decision**: 实现分层错误处理系统，按严重程度（致命/警告/信息）和类型（配置/系统/用户）分类。

**Rationale**:
- 提供清晰的错误分类和优先级
- 改善用户体验和问题诊断
- 便于维护和扩展
- 符合 macOS 应用标准

**Alternatives considered**:
- 简单错误处理：用户体验差，难以诊断问题
- 过度复杂的错误系统：开发成本高，用户困惑

## Technical Implementation Details

### 1. Core Data 配置优化

```swift
// 高性能 Core Data 设置
class CoreDataStack {
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel")

        // 性能优化配置
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        // 启用历史追踪和远程变更通知
        container.persistentStoreDescriptions.first?.setOption(true as NSNumber,
                                                               forKey: NSPersistentHistoryTrackingKey)

        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data failed to load: \(error)")
            }
        }

        return container
    }()
}
```

### 2. 资源管理系统

```swift
class ResourceManager {
    private let bundle: Bundle

    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    func getHelpContent(for topic: String) -> String? {
        guard let url = bundle.url(forResource: "Help/\(topic)", withExtension: "md"),
              let data = try? Data(contentsOf: url) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    func getErrorMessage(for code: String) -> String? {
        guard let url = bundle.url(forResource: "ErrorMessages", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let errorMessages = try? JSONDecoder().decode([String: String].self, from: data) else {
            return nil
        }
        return errorMessages[code]
    }
}
```

### 3. iTerm2 集成实现

```swift
class ITerm2Launcher {
    func launchWithConfiguration(_ config: Configuration) throws {
        let script = """
        tell application "iTerm2"
            activate
            create window with default profile
            tell current session of current window
                write text "cd \(config.workingDirectory)"
                write text "export ANTHROPIC_API_KEY=\(config.apiKey)"
                write text "export ANTHROPIC_BASE_URL=\(config.baseURL)"
                write text "claude-code"
            end tell
        end tell
        """

        var error: NSDictionary?
        guard let appleScript = NSAppleScript(source: script),
              appleScript.executeAndReturnError(&error) != nil else {
            throw AppError.operationFailed("Failed to launch iTerm2")
        }
    }
}
```

### 4. 安全存储实现

```swift
class KeychainManager {
    private let service = "com.claudecode.config"

    func saveAPIKey(_ key: String, forProvider provider: String) throws {
        guard let keyData = key.data(using: .utf8) else {
            throw AppError.validationError("Invalid API key format")
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: provider,
            kSecValueData as String: keyData
        ]

        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw AppError.securityError("Failed to save API key")
        }
    }
}
```

## Performance Considerations

### 1. 启动时间优化 (< 2秒)

- **预加载 Core Data**: 应用启动时异步初始化数据存储
- **延迟加载资源**: 按需加载帮助文档和模板
- **缓存机制**: 缓存常用配置和验证结果
- **后台处理**: 将耗时操作移至后台队列

### 2. 响应时间优化 (< 1秒)

- **异步操作**: 所有 I/O 操作使用 async/await
- **内存缓存**: 缓存配置数据和验证结果
- **批量操作**: 优化数据库查询和文件操作
- **UI 更新优化**: 使用 @Published 和 @StateObject 合理管理状态

### 3. 内存使用优化 (< 50MB)

- **懒加载**: 按需加载大型资源文件
- **数据分页**: Core Data 查询使用分页
- **图片优化**: 压缩内置资源文件
- **内存管理**: 及时释放不需要的对象

## Security Considerations

### 1. 敏感信息保护

- **Keychain 存储**: 所有 API 密钥使用系统钥匙串
- **内存清理**: 及时清理内存中的敏感信息
- **日志过滤**: 确保敏感信息不出现在日志中
- **权限控制**: 配置文件使用适当的文件权限

### 2. 数据完整性

- **输入验证**: 严格验证所有用户输入
- **数据校验**: 配置文件导入时进行完整性检查
- **错误处理**: 安全地处理所有错误情况
- **版本兼容**: 处理配置文件版本升级

## Testing Strategy

### 1. 离线环境测试

- **网络断开测试**: 完全断网环境下验证所有功能
- **资源可用性**: 确保内置资源在所有情况下可访问
- **错误恢复**: 测试各种错误场景的恢复能力
- **性能基准**: 验证响应时间和内存使用符合要求

### 2. 集成测试

- **iTerm2 集成**: 测试与 iTerm2 的启动和通信
- **Core Data 测试**: 验证数据持久化和查询性能
- **Keychain 测试**: 确保敏感信息的安全存储
- **UI 测试**: 验证用户界面的响应性和正确性

## Compliance and Standards

### 1. macOS 开发规范

- **SwiftUI 最佳实践**: 使用现代 SwiftUI 开发模式
- **AppKit 集成**: 必要时使用 AppKit 进行系统集成
- **沙盒兼容**: 确保应用在沙盒环境中正常运行
- **代码签名**: 遵循 macOS 应用分发规范

### 2. 中文交互原则

- **界面本地化**: 所有界面元素使用中文
- **错误信息中文化**: 错误提示和帮助文档使用中文
- **文档注释**: 代码注释使用中文编写
- **用户指导**: 提供中文版用户使用指南

## Risk Assessment

### 1. 技术风险

- **Core Data 兼容性**: macOS 版本升级可能影响数据模型
- **iTerm2 集成**: iTerm2 版本更新可能影响 AppleScript 兼容性
- **性能瓶颈**: 大量配置文件可能影响应用性能
- **内存泄漏**: 长期运行可能存在内存泄漏风险

### 2. 缓解措施

- **版本兼容性测试**: 在多个 macOS 版本上进行测试
- **向后兼容**: 保持与旧版本 iTerm2 的兼容性
- **性能监控**: 实现性能监控和报警机制
- **定期测试**: 建立自动化测试和性能基准

## Implementation Timeline

### Phase 1: 基础架构 (1-2周)
- Core Data 数据模型设计
- 基础 SwiftUI 界面框架
- 错误处理系统实现
- 资源管理系统开发

### Phase 2: 核心功能 (2-3周)
- 配置管理功能实现
- iTerm2 集成开发
- Keychain 安全存储
- 本地验证器开发

### Phase 3: 优化和测试 (1-2周)
- 性能优化和调试
- 离线环境测试
- 用户界面优化
- 文档和帮助内容完善

## Success Metrics

- **功能完整性**: 100% 核心功能在离线环境下正常工作
- **性能指标**: 启动时间 < 2秒，操作响应 < 1秒
- **用户体验**: 错误处理覆盖率 > 95%
- **稳定性**: 连续运行 24小时无崩溃
- **资源效率**: 内存使用 < 50MB，支持 1000+ 配置文件