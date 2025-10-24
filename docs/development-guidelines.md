# Claude Code配置工具开发指导文档

## 开发环境设置

### 必需工具
- Xcode 16.0+
- Python 3.11+
- Swift 6.0+
- Git

### 项目初始化
```bash
# 克隆项目
git clone <repository-url>
cd claude_code_config_tool

# 安装Python依赖
pip install -r requirements.txt

# 打开Xcode项目
open ClaudeCodeConfig.xcodeproj
```

## 章程遵循指导

### 用户体验优先原则
- 所有UI组件必须使用SwiftUI构建
- 响应时间监控：使用`os_signpost`进行性能追踪
- 错误处理必须提供用户友好的消息
- 每个配置项需要工具提示说明

```swift
// 性能监控示例
import os.signpost

let log = OSLog(subsystem: "com.claudecode.config", category: "Performance")
os_signpost(.begin, log: log, name: "ConfigLoad")
// 配置加载逻辑
os_signpost(.end, log: log, name: "ConfigLoad")
```

### 环境配置灵活性实现
- 使用Codable协议支持JSON/YAML格式
- 提供Provider协议支持扩展
- 配置验证必须在使用前完成

```swift
protocol ModelProvider {
    var name: String { get }
    var requiredEnvironmentVars: [String] { get }
    func validate(config: [String: String]) -> Bool
}
```

### 系统集成深度要求
- 使用NSWorkspace进行系统集成
- 实现Spotlight搜索索引
- 支持菜单栏扩展
- iTerm2通过AppleScript控制

```swift
// iTerm2启动示例
@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func launchiTerm2(withDirectory directory: String) {
        let script = """
        tell application "iTerm2"
            create window with default profile
            tell current session of current window
                write text "cd \(directory)"
                write text "claude-code"
            end tell
            activate
        end tell
        """
        // 执行AppleScript
    }
}
```

### 安全性保障实现
- 使用Keychain存储API密钥
- 配置文件权限控制
- 日志脱敏处理

```swift
import Security

class KeychainManager {
    static func storeAPIKey(_ key: String, forProvider provider: String) throws {
        // Keychain存储实现
    }

    static func retrieveAPIKey(forProvider provider: String) throws -> String? {
        // Keychain检索实现
    }
}
```

### 可扩展性设计
- 插件系统基于Bundle加载
- 配置模板化
- 核心功能协议化

```swift
protocol ConfigPlugin {
    var identifier: String { get }
    var version: String { get }
    func loadConfig() -> ConfigModel
    func validateConfig(_ config: ConfigModel) -> ValidationResult
}
```

## 开发约定

### 系统时间获取约定
**重要**: 在本项目中，当需要获取系统时间时，必须使用MCP datetime工具，而不是直接使用系统时间函数。

#### 正确做法:
```python
# 通过MCP工具获取时间
result = mcp_call_tool("get_current_time")
current_time = json.loads(result["content"][0]["text"])
```

#### 错误做法:
```python
# 禁止直接使用datetime模块
import datetime
now = datetime.datetime.now()  # ❌ 不要这样做
```

#### 理由:
- 统一时间获取方式，确保一致性
- 支持多种时间格式和时区
- 便于测试和维护
- 符合项目的MCP架构设计

## 代码规范

### Swift代码规范
- 使用SwiftLint进行代码风格检查
- 函数命名使用动词开头
- 类型命名使用PascalCase
- 变量命名使用camelCase

### Python代码规范
- 使用Black进行格式化
- 使用flake8进行静态检查
- 类型注解必须完整
- 文档字符串使用Google风格

## 测试策略

### 单元测试
- 每个类必须有对应的测试类
- 测试覆盖率目标80%+
- 关键路径100%覆盖
- 使用Quick/Nimble进行BDD测试

### UI测试
- 使用XCUITest框架
- 关键用户路径必须有UI测试
- 性能测试使用XCTestMetrics

### 集成测试
- 端到端用户场景测试
- 与iTerm2的集成测试
- Keychain功能测试

## 发布检查清单

### 代码质量
- [ ] 所有测试通过
- [ ] 代码覆盖率达标
- [ ] SwiftLint/Black检查通过
- [ ] 静态分析无严重问题

### 性能验证
- [ ] 启动时间 < 2秒
- [ ] 配置加载 < 500毫秒
- [ ] 内存使用 < 50MB
- [ ] 支持1000+配置文件测试

### 安全审查
- [ ] 敏感信息Keychain存储
- [ ] 日志脱敏验证
- [ ] 权限控制检查
- [ ] API密钥加密验证

### 兼容性测试
- [ ] macOS 26+ 测试
- [ ] iTerm2 3.4.x+ 测试
- [ ] Claude Code兼容性测试

## 常见问题解决

### 性能问题
1. 使用Instruments进行性能分析
2. 检查Core Data查询优化
3. 验证UI更新在主线程

### 内存泄漏
1. 使用Leaks工具检测
2. 注意闭包循环引用
3. Core Data上下文管理

### 权限问题
1. 检查Info.plist权限声明
2. 验证Keychain访问权限
3. 确认文件系统权限

## 扩展开发

### 新增模型提供商
1. 实现ModelProvider协议
2. 创建配置模板
3. 添加验证逻辑
4. 编写测试用例

### 新增功能插件
1. 实现ConfigPlugin协议
2. 创建Bundle项目
3. 注册插件机制
4. 文档和测试

此文档应与章程保持同步更新，任何章程修改都应该反映在此指导文档中。