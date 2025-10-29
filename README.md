# Claude Code Config

<div align="center">

![Claude Code Config](https://img.shields.io/badge/version-1.1.4-blue.svg)
![Platform](https://img.shields.io/badge/platform-macOS%2013.0+-lightgrey.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Swift](https://img.shields.io/badge/Swift-6.0+-orange.svg)

**Claude Code CLI 配置管理工具**

一个专为 macOS 设计的 Claude Code CLI 图形化配置管理工具，提供直观的界面来管理开发环境配置。

</div>

## ✨ 功能特性

### 🎯 核心功能
- **配置管理**: 创建、编辑、删除 Claude Code CLI 配置
- **项目分组**: 支持配置分组和颜色标识，便于组织管理
- **系统状态栏集成**: macOS 顶部状态栏快速访问
- **一键启动**: 自动生成启动命令并复制到剪贴板
- **危险模式支持**: 支持 `--dangerously-skip-permissions` 参数

### 🎨 用户界面
- **现代化设计**: 基于 SwiftUI 的原生 macOS 界面
- **深色/浅色模式**: 自动适配系统主题
- **分组颜色标识**: 6种颜色区分不同项目类型
- **实时状态反馈**: 操作结果即时显示

### 🛡️ 安全特性
- **二次确认**: 删除分组时的确认对话框
- **数据保护**: 自动备份配置到默认分组
- **权限管理**: 智能处理文件访问权限

## 📸 应用截图

```
┌─────────────────────────────────────────────────────────┐
│  CCC Config                                    [⚡ 退出] │
│  Claude Code CLI 配置管理工具                            │
├─────────────────────────────────────────────────────────┤
│  [全部配置(3)] [🔵默认分组(2)] [🟢工作项目(1)] [...] [➕] │
├─────────────────────────────────────────────────────────┤
│  ⚙️ 工作项目配置                                    [复制] [启动] [编辑] │
│     🔵 工作项目  ⚠️ 危险模式  默认                      │
│     /Users/weimingxu/Documents/Projects                │
├─────────────────────────────────────────────────────────┤
│                                                     [+ 添加配置] │
├─────────────────────────────────────────────────────────┤
│               开发者: weiming                           │
│          联系邮箱: swimming.xwm@gmail.com               │
└─────────────────────────────────────────────────────────┘
```

## 🚀 快速开始

### 系统要求

- **操作系统**: macOS 13.0 (Ventura) 或更高版本
- **处理器**: Intel Mac 或 Apple Silicon Mac
- **依赖**: Claude Code CLI, iTerm2

### 安装方法

#### 方法一：下载预编译版本 (推荐)

1. 下载最新的 `ClaudeCodeConfig.app`
2. 将应用拖拽到 `Applications` 文件夹
3. 首次运行时可能需要允许应用运行

#### 方法二：从源码编译

```bash
# 克隆仓库
git clone https://github.com/your-repo/claude-code-config.git
cd claude-code-config

# 编译并安装
./build_and_deploy.sh

# 应用将自动安装到 Applications 文件夹
```

### 首次使用

1. **启动应用**: 在 Applications 文件夹中找到 Claude Code Config
2. **创建配置**: 点击"添加配置"按钮
3. **填写信息**:
   - 配置名称 (例如: 工作项目)
   - API URL (默认: https://api.anthropic.com)
   - API Key (从 Anthropic 官网获取)
   - 工作目录 (项目根目录路径)
4. **保存配置**: 点击"保存"完成创建
5. **启动项目**: 点击配置的"启动"按钮，命令会自动复制到剪贴板

## 📖 使用指南

### 配置管理

#### 创建新配置
1. 点击"添加配置"按钮
2. 填写配置信息
3. 选择所属分组（可选）
4. 设置危险模式（如需要）
5. 保存配置

#### 编辑配置
1. 在配置列表中找到要编辑的配置
2. 点击配置右侧的"编辑"按钮
3. 修改配置信息
4. 保存更改

#### 删除配置
1. 在配置编辑界面
2. 点击"删除配置"按钮
3. 确认删除操作

### 分组管理

#### 创建分组
1. 点击分组选择器右侧的"新建分组"按钮
2. 输入分组名称
3. 选择分组颜色
4. 点击"创建"保存

#### 编辑分组
1. 将鼠标悬停在分组名称上
2. 点击分组右侧的编辑按钮（铅笔图标）
3. 修改分组信息
4. 保存更改

#### 删除分组
1. 点击分组右侧的删除按钮（红色减号图标）
2. 在确认对话框中点击"删除"
3. 该分组的所有配置将自动移到默认分组

### 启动配置

#### 方法一：应用内启动
1. 选择要启动的配置
2. 点击"启动"按钮
3. 启动命令会自动复制到剪贴板
4. 在终端中粘贴并执行

#### 方法二：状态栏启动
1. 点击顶部状态栏的齿轮图标
2. 选择"启动配置"或使用快捷键 `⌘⇧L`
3. 默认配置的启动命令会复制到剪贴板

## ⚙️ 配置选项

### 基础配置
- **配置名称**: 配置的显示名称
- **API URL**: Claude API 端点地址
- **API Key**: Anthropic API 密钥
- **工作目录**: 项目根目录路径
- **模型名称**: 使用的 Claude 模型（可选）

### 高级选项
- **危险模式**: 跳过权限检查，适用于可信环境
- **默认配置**: 标记为默认启动配置
- **所属分组**: 配置所属的项目分组

### 分组设置
- **分组名称**: 分组的显示名称
- **分组颜色**: 6种颜色可选（蓝、绿、红、橙、紫、粉）
- **排序**: 分组在列表中的显示顺序

## 🔧 快捷键

| 功能 | 快捷键 | 说明 |
|------|--------|------|
| 启动配置 | `⌘⇧L` | 快速启动默认配置 |
| 退出应用 | `⌘Q` | 关闭应用 |
| 显示帮助 | `?` | 显示使用说明 |

## 🏗️ 技术架构

### 技术栈
- **语言**: Swift 6.0+
- **框架**: SwiftUI
- **架构**: MVVM
- **数据存储**: JSON 文件 + Keychain
- **系统集成**: NSStatusItem, AppleScript

### 项目结构
```
claude-code-config/
├── src/
│   └── main.swift          # 主要源代码文件
├── build_and_deploy.sh     # 构建和部署脚本
├── CLAUDE.md              # 开发指南
├── README.md              # 项目说明
├── .gitignore             # Git 忽略规则
└── .git/                  # Git 仓库
```

### 数据存储
- **配置数据**: `~/Library/Application Support/cccfg/configs.json`
- **分组数据**: `~/Library/Application Support/cccfg/groups.json`
- **敏感信息**: macOS Keychain (API Keys)

## 🛠️ 开发

### 环境要求
- Xcode 16.0+
- Swift 6.0+
- macOS 13.0+

### 构建命令
```bash
# 构建应用
./build_and_deploy.sh

# 自定义构建
swiftc -target x86_64-app-macos13.0 src/main.swift -o build/ClaudeCodeConfig-x86_64
swiftc -target arm64-app-macos13.0 src/main.swift -o build/ClaudeCodeConfig-arm64
lipo -create build/ClaudeCodeConfig-x86_64 build/ClaudeCodeConfig-arm64 -output build/ClaudeCodeConfig
```

### 调试模式
```bash
# 编译调试版本
swiftc -g -target x86_64-app-macos13.0 src/main.swift -o ClaudeCodeConfig-debug

# 运行调试
./ClaudeCodeConfig-debug
```

## 🐛 故障排除

### 常见问题

**Q: 应用启动后没有反应？**
A: 检查系统权限设置，确保应用有文件访问权限。

**Q: 启动命令复制失败？**
A: 检查剪贴板权限，在系统偏好设置中允许应用访问剪贴板。

**Q: 状态栏图标不显示？**
A: 重新启动应用，或检查系统设置中的状态栏权限。

**Q: 配置数据丢失？**
A: 检查 `~/Library/Application Support/cccfg/` 目录是否存在。

### 日志查看
```bash
# 查看系统日志
log stream --predicate 'process == "ClaudeCodeConfig"'

# 查看崩溃报告
console /Users/username/Library/Logs/DiagnosticReports/
```

## 📝 更新日志

### v1.1.4 (2025-10-29)
- ✨ 新增开发者信息显示
- 🎨 优化分组颜色显示
- 🛡️ 改进删除确认机制
- 🐛 修复分组编辑功能

### v1.1.3 (2025-10-29)
- 🛠️ 禁用文本自动填充功能
- 🎯 优化用户输入体验

### v1.1.2 (2025-10-29)
- 🗑️ 新增分组删除功能
- 🚪 添加应用内退出按钮
- 📊 实时更新分组统计

### v1.1.1 (2025-10-29)
- 🔧 修复顶部任务栏显示问题
- ⚡ 恢复启动和复制命令功能
- ➕ 新增分组创建功能

### v1.1.0 (2025-10-29)
- 🎉 初始版本发布
- ✨ 基础配置管理功能
- 🎨 项目分组功能
- 🚫 危险模式支持

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 👨‍💻 开发者

- **开发者**: weiming
- **邮箱**: swimming.xwm@gmail.com
- **版权**: Copyright © 2025 weiming. All rights reserved.

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

1. Fork 本仓库
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开 Pull Request

## 🙏 致谢

- [Anthropic](https://anthropic.com) - Claude API 提供商
- [SwiftUI](https://developer.apple.com/xcode/swiftui/) - 用户界面框架
- [iTerm2](https://iterm2.com/) - 终端模拟器

---

<div align="center">

**[⬆️ 返回顶部](#claude-code-config)**

Made with ❤️ by weiming

</div>