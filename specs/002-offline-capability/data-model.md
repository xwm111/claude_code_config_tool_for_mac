# Data Model: 离线使用能力

**Date**: 2025-10-23
**Feature**: 离线使用能力特性
**Phase**: 1 - Data Model & Contracts

## Entity Overview

### Core Entities

#### 1. Configuration (配置文件)
```swift
@objc(Configuration)
public class Configuration: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var baseURL: String
    @NSManaged public var workingDirectory: String
    @NSManaged public var isDefault: Bool
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    @NSManaged public var validationState: Int16 // 0: 未验证, 1: 有效, 2: 无效
    @NSManaged public var lastValidationDate: Date?
    @NSManaged public var validationErrors: String? // JSON string
}
```

**Attributes**:
- `id`: 唯一标识符，UUID 格式
- `name`: 配置名称，用户友好的显示名称
- `baseURL`: API 基础 URL，存储加密后的值
- `workingDirectory`: 工作目录路径
- `isDefault`: 是否为默认配置
- `createdAt`: 创建时间
- `updatedAt`: 最后更新时间
- `validationState`: 验证状态（0=未验证, 1=有效, 2=无效）
- `lastValidationDate`: 最后验证时间
- `validationErrors`: 验证错误信息（JSON 格式）

**Relationships**: 无直接关系，独立实体

**Validation Rules**:
- `name`: 必填，1-50字符，唯一性约束
- `baseURL`: 必填，有效 URL 格式
- `workingDirectory`: 必填，有效路径且存在
- `isDefault`: 只能有一个配置为默认

**State Transitions**:
```
创建 → 验证中 → 有效/无效
编辑 → 验证中 → 有效/无效
删除 → 已删除
```

#### 2. ValidationError (验证错误)
```swift
@objc(ValidationError)
public class ValidationError: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var configurationID: UUID
    @NSManaged public var errorType: String // "CONFIG", "SYSTEM", "USER"
    @NSManaged public var severity: String // "FATAL", "WARNING", "INFO"
    @NSManaged public var code: String
    @NSManaged public var message: String
    @NSManaged public var suggestion: String?
    @NSManaged public var createdAt: Date
    @NSManaged public var isResolved: Bool
}
```

**Attributes**:
- `id`: 唯一标识符
- `configurationID`: 关联的配置 ID
- `errorType`: 错误类型（配置/系统/用户）
- `severity`: 严重程度（致命/警告/信息）
- `code`: 错误代码
- `message`: 错误消息
- `suggestion`: 解决建议
- `createdAt`: 创建时间
- `isResolved`: 是否已解决

**Relationships**: 与 Configuration 弱关联

#### 3. SystemResource (系统资源)
```swift
@objc(SystemResource)
public class SystemResource: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var resourceType: String // "HELP_DOC", "TEMPLATE", "ERROR_MESSAGE"
    @NSManaged public var resourceKey: String
    @NSManaged public var content: String
    @NSManaged public var version: String
    @NSManaged public var isBuiltIn: Bool
    @NSManaged public var lastAccessed: Date?
    @NSManaged public var accessCount: Int32
}
```

**Attributes**:
- `id`: 唯一标识符
- `resourceType`: 资源类型
- `resourceKey`: 资源键值
- `content`: 资源内容
- `version`: 资源版本
- `isBuiltIn`: 是否为内置资源
- `lastAccessed`: 最后访问时间
- `accessCount`: 访问次数

## Data Access Layer

### Repository Pattern

```swift
protocol Repository {
    associatedtype Entity: NSManagedObject
    func getAll() async throws -> [Entity]
    func get(by id: UUID) async throws -> Entity?
    func save(_ entity: Entity) async throws
    func delete(_ entity: Entity) async throws
    func delete(by id: UUID) async throws
}

class ConfigurationRepository: Repository {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func getAll() async throws -> [Configuration] {
        let request: NSFetchRequest<Configuration> = Configuration.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Configuration.updatedAt, ascending: false)]
        return try context.fetch(request)
    }

    func getDefault() async throws -> Configuration? {
        let request: NSFetchRequest<Configuration> = Configuration.fetchRequest()
        request.predicate = NSPredicate(format: "isDefault == true")
        request.fetchLimit = 1
        return try context.fetch(request).first
    }

    func setDefault(_ configuration: Configuration) async throws {
        // 取消所有其他配置的默认状态
        let allConfigs = try await getAll()
        for config in allConfigs {
            config.isDefault = false
        }
        configuration.isDefault = true
        try await save(configuration)
    }

    func getByName(_ name: String) async throws -> Configuration? {
        let request: NSFetchRequest<Configuration> = Configuration.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", name)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }

    // 其他 CRUD 操作...
}
```

### Validation Service

```swift
protocol ValidationService {
    func validateConfiguration(_ configuration: Configuration) async throws -> ValidationResult
    func validateWorkingDirectory(_ path: String) -> ValidationResult
    func validateBaseURL(_ url: String) -> ValidationResult
}

struct ValidationResult {
    let isValid: Bool
    let errors: [ValidationError]
    let warnings: [ValidationError]

    var hasErrors: Bool { !errors.isEmpty }
    var hasWarnings: Bool { !warnings.isEmpty }
}

class LocalValidationService: ValidationService {
    private let fileManager = FileManager.default
    private let context: NSManagedObjectContext

    func validateConfiguration(_ configuration: Configuration) async throws -> ValidationResult {
        var errors: [ValidationError] = []
        var warnings: [ValidationError] = []

        // 验证配置名称
        if configuration.name.isEmpty {
            errors.append(ValidationError(
                code: "EMPTY_NAME",
                message: "配置名称不能为空",
                severity: .fatal,
                type: .config
            ))
        }

        // 验证基础 URL
        let urlResult = validateBaseURL(configuration.baseURL)
        errors.append(contentsOf: urlResult.errors)
        warnings.append(contentsOf: urlResult.warnings)

        // 验证工作目录
        let dirResult = validateWorkingDirectory(configuration.workingDirectory)
        errors.append(contentsOf: dirResult.errors)
        warnings.append(contentsOf: dirResult.warnings)

        return ValidationResult(
            isValid: errors.isEmpty,
            errors: errors,
            warnings: warnings
        )
    }

    func validateWorkingDirectory(_ path: String) -> ValidationResult {
        var errors: [ValidationError] = []
        var warnings: [ValidationError] = []

        if path.isEmpty {
            errors.append(ValidationError(
                code: "EMPTY_DIRECTORY",
                message: "工作目录不能为空",
                severity: .fatal,
                type: .config
            ))
        } else if !fileManager.fileExists(atPath: path) {
            errors.append(ValidationError(
                code: "DIRECTORY_NOT_FOUND",
                message: "工作目录不存在: \(path)",
                severity: .fatal,
                type: .config
            ))
        } else if !fileManager.isReadableFile(atPath: path) {
            errors.append(ValidationError(
                code: "DIRECTORY_NOT_READABLE",
                message: "工作目录不可读: \(path)",
                severity: .fatal,
                type: .system
            ))
        }

        return ValidationResult(isValid: errors.isEmpty, errors: errors, warnings: warnings)
    }

    func validateBaseURL(_ url: String) -> ValidationResult {
        var errors: [ValidationError] = []
        var warnings: [ValidationError] = []

        if url.isEmpty {
            errors.append(ValidationError(
                code: "EMPTY_URL",
                message: "API 基础 URL 不能为空",
                severity: .fatal,
                type: .config
            ))
        } else if !isValidURL(url) {
            errors.append(ValidationError(
                code: "INVALID_URL",
                message: "URL 格式无效: \(url)",
                severity: .fatal,
                type: .config
            ))
        } else if !url.hasPrefix("https://") && !url.hasPrefix("http://") {
            warnings.append(ValidationError(
                code: "INSECURE_PROTOCOL",
                message: "建议使用 HTTPS 协议以确保安全性",
                severity: .warning,
                type: .config
            ))
        }

        return ValidationResult(isValid: errors.isEmpty, errors: errors, warnings: warnings)
    }

    private func isValidURL(_ url: String) -> Bool {
        guard let url = URL(string: url) else { return false }
        return url.scheme != nil && url.host != nil
    }
}
```

## JSON Contracts

### Configuration Export Format

```json
{
  "version": "1.0",
  "exportedAt": "2025-10-23T11:30:00Z",
  "configurations": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "name": "默认配置",
      "baseURL": "https://api.anthropic.com",
      "workingDirectory": "/Users/username/projects",
      "isDefault": true,
      "createdAt": "2025-10-23T10:00:00Z",
      "updatedAt": "2025-10-23T11:00:00Z"
    }
  ]
}
```

### Error Message Format

```json
{
  "version": "1.0",
  "errors": {
    "EMPTY_NAME": {
      "message": "配置名称不能为空",
      "suggestion": "请输入一个描述性的配置名称",
      "severity": "FATAL",
      "type": "CONFIG"
    },
    "DIRECTORY_NOT_FOUND": {
      "message": "工作目录不存在",
      "suggestion": "请检查目录路径是否正确，或创建该目录",
      "severity": "FATAL",
      "type": "CONFIG"
    },
    "ITERM_NOT_FOUND": {
      "message": "未找到 iTerm2 应用程序",
      "suggestion": "请确保已安装 iTerm2，或从官网下载安装",
      "severity": "FATAL",
      "type": "SYSTEM"
    }
  }
}
```

### Help Documentation Structure

```json
{
  "version": "1.0",
  "helpTopics": [
    {
      "key": "getting-started",
      "title": "快速开始",
      "content": "帮助文档内容...",
      "category": "basic",
      "lastUpdated": "2025-10-23T10:00:00Z"
    },
    {
      "key": "configuration",
      "title": "配置管理",
      "content": "配置帮助内容...",
      "category": "advanced",
      "lastUpdated": "2025-10-23T11:00:00Z"
    }
  ]
}
```

## API Contracts

### Configuration Management API

```swift
protocol ConfigurationAPI {
    // CRUD 操作
    func createConfiguration(_ config: ConfigurationCreateRequest) async throws -> Configuration
    func getConfiguration(id: UUID) async throws -> Configuration
    func updateConfiguration(_ config: ConfigurationUpdateRequest) async throws -> Configuration
    func deleteConfiguration(id: UUID) async throws

    // 批量操作
    func getAllConfigurations() async throws -> [Configuration]
    func importConfigurations(from url: URL) async throws -> [Configuration]
    func exportConfigurations(_ configs: [Configuration], to url: URL) async throws

    // 验证操作
    func validateConfiguration(_ config: Configuration) async throws -> ValidationResult
    func validateAllConfigurations() async throws -> [UUID: ValidationResult]

    // 启动操作
    func launchWithConfiguration(_ config: Configuration) async throws
}

struct ConfigurationCreateRequest {
    let name: String
    let baseURL: String
    let workingDirectory: String
    let isDefault: Bool
}

struct ConfigurationUpdateRequest {
    let id: UUID
    let name: String?
    let baseURL: String?
    let workingDirectory: String?
    let isDefault: Bool?
}
```

### Resource Management API

```swift
protocol ResourceAPI {
    func getHelpContent(for topic: String) async throws -> String?
    func getAllHelpTopics() async throws -> [HelpTopic]
    func getErrorMessage(for code: String) async throws -> String?
    func getResource(type: ResourceType, key: String) async throws -> String?
}

struct HelpTopic {
    let key: String
    let title: String
    let content: String
    let category: HelpCategory
    let lastUpdated: Date
}

enum ResourceType: String, CaseIterable {
    case helpDoc = "HELP_DOC"
    case template = "TEMPLATE"
    case errorMessage = "ERROR_MESSAGE"
}

enum HelpCategory: String, CaseIterable {
    case basic = "basic"
    case advanced = "advanced"
    case troubleshooting = "troubleshooting"
}
```

## Data Migration Strategy

### Version 1.0 → 1.1 Migration

```swift
class DataMigrationManager {
    func migrateToVersion1_1() async throws {
        // 添加新字段 validationState
        // 添加新实体 ValidationError
        // 更新现有配置的验证状态
    }

    func migrateToVersion1_2() async throws {
        // 添加新实体 SystemResource
        // 迁移内置资源到数据库
        // 更新资源访问统计
    }
}
```

## Performance Considerations

### 1. Core Data Optimization

- **Batch Operations**: 使用批量操作处理大量数据
- **Background Context**: 在后台上下文执行耗时操作
- **Fetch Limits**: 使用 fetchLimit 限制查询结果数量
- **Indexing**: 为常用查询字段添加索引

### 2. Memory Management

- **Lazy Loading**: 按需加载大型对象和资源
- **Weak References**: 使用弱引用避免循环引用
- **Object Lifecycle**: 及时释放不需要的对象

### 3. Caching Strategy

- **In-Memory Cache**: 缓存频繁访问的配置数据
- **Resource Cache**: 缓存帮助文档和错误信息
- **Validation Cache**: 缓存验证结果避免重复验证

## Security Considerations

### 1. Data Protection

- **Encryption**: 敏感数据使用 Keychain 加密存储
- **Access Control**: 实施适当的文件访问权限
- **Data Sanitization**: 输入数据验证和清理

### 2. Privacy Protection

- **Local Storage**: 所有数据仅存储在本地
- **No Telemetry**: 不收集或传输用户数据
- **Secure Deletion**: 安全删除敏感信息

## Testing Strategy

### 1. Unit Testing

```swift
class ConfigurationRepositoryTests: XCTestCase {
    func testCreateConfiguration() async throws {
        // 测试配置创建
    }

    func testValidationRules() async throws {
        // 测试验证规则
    }

    func testDefaultConfiguration() async throws {
        // 测试默认配置逻辑
    }
}
```

### 2. Integration Testing

```swift
class ConfigurationIntegrationTests: XCTestCase {
    func testImportExportRoundTrip() async throws {
        // 测试导入导出功能
    }

    func testConcurrentAccess() async throws {
        // 测试并发访问
    }
}
```

### 3. Performance Testing

```swift
class PerformanceTests: XCTestCase {
    func testConfigurationLoadTime() {
        // 测试配置加载性能
    }

    func testMemoryUsage() {
        // 测试内存使用情况
    }
}
```

## Success Metrics

- **Data Integrity**: 100% 数据完整性验证通过
- **Performance**: 配置操作响应时间 < 100ms
- **Reliability**: 数据操作成功率 > 99.9%
- **Scalability**: 支持 10,000+ 配置文件
- **Migration**: 数据迁移成功率 100%