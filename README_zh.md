# Claude Code Config

<div align="center">

![Version](https://img.shields.io/badge/version-1.1.4-blue.svg)
![Platform](https://img.shields.io/badge/platform-macOS%2013.0+-lightgrey.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)

**Claude Code CLI 图形化配置管理工具**

一个简洁高效的 macOS 原生应用，帮助你管理多个 Claude Code CLI 配置。

中文 | [English](README.md)

</div>

---

## ✨ 主要特性

- 🎯 **配置管理** - 创建、编辑、删除和管理多个 Claude Code CLI 配置
- 📁 **分组组织** - 使用颜色编码的分组功能，轻松组织不同项目
- 🚀 **一键启动** - 直接在 iTerm2 中启动配置，无需手动输入命令
- 📋 **命令复制** - 快速复制启动命令到剪贴板
- 🌐 **国际化支持** - 完整的中英文双语界面
- 🎨 **现代化 UI** - 基于 SwiftUI 的原生 macOS 界面设计
- 💾 **本地存储** - 配置数据安全存储在本地 JSON 文件

## 🚀 快速开始

### 系统要求

- **macOS**: 13.0 (Ventura) 或更高版本
- **处理器**: Intel 或 Apple Silicon (Universal Binary)
- **依赖软件**: 
  - [Claude Code CLI](https://github.com/anthropics/claude-code) - 必须安装
  - [iTerm2](https://iterm2.com/) - 用于启动功能

### 安装

#### 从源码构建（推荐）

```bash
# 1. 克隆仓库
git clone <repository-url>
cd claude-code-config-tool

# 2. 构建应用
./build_and_deploy.sh

# 应用将生成在项目根目录：ClaudeCodeConfig.app
```

#### 使用预编译版本

1. 下载最新的 `ClaudeCodeConfig.app`
2. 将应用拖拽到 `Applications` 文件夹
3. 首次运行可能需要在"系统设置 > 隐私与安全性"中允许运行

## 📖 使用指南

### 创建配置

1. 启动应用，点击"创建新配置"按钮
2. 填写以下信息：
   - **配置名称**: 便于识别的名称（如：工作项目、个人项目）
   - **API URL**: Claude API 端点（默认：`https://api.anthropic.com`）
   - **API Key**: 从 Anthropic 获取的 API 密钥
   - **工作目录**: 项目根目录路径
   - **模型名称**: (可选) 指定 Claude 模型版本
3. 可选设置：
   - **危险模式**: 启用 `--dangerously-skip-permissions` 参数
   - **所属分组**: 选择配置所属的项目分组
4. 点击"保存配置"完成创建

### 管理分组

#### 创建分组

1. 点击分组选择器旁的 "+" 按钮
2. 输入分组名称和选择颜色
3. 保存分组

#### 编辑/删除分组

- 点击分组列表中的编辑图标 ✏️ 进行修改
- 点击删除图标 🗑️ 删除分组（该分组的配置会自动移到默认分组）

### 启动配置

应用提供两种启动方式：

#### 方式一：直接启动 iTerm2

1. 在配置列表中找到目标配置
2. 点击"启动"按钮
3. 应用会自动打开 iTerm2 并在新标签页中执行启动命令

#### 方式二：复制命令

1. 点击配置的"复制命令"按钮
2. 启动命令已复制到剪贴板
3. 在终端中粘贴并执行

## 🏗️ 项目结构

```
claude-code-config-tool/
├── src/                          # 源代码目录
│   ├── main.swift                # 应用入口和 AppDelegate
│   ├── Models/                   # 数据模型
│   │   ├── Config.swift          # 配置模型
│   │   └── ConfigGroup.swift     # 分组模型
│   ├── Views/                    # SwiftUI 视图
│   │   ├── ContentView.swift     # 主视图
│   │   ├── ConfigEditView.swift  # 配置编辑视图
│   │   ├── SimpleGroupEditView.swift  # 分组编辑视图
│   │   ├── LanguageSwitcher.swift    # 语言切换器
│   │   └── CyberpunkToast.swift      # Toast 通知组件
│   ├── Services/                 # 业务逻辑层
│   │   ├── ConfigManager.swift   # 配置管理服务
│   │   ├── GroupManager.swift    # 分组管理服务
│   │   └── CLILauncher.swift    # CLI 启动服务
│   ├── Utilities/                # 工具类
│   │   ├── Constants.swift       # 应用常量
│   │   ├── WindowManager.swift   # 窗口管理
│   │   └── LocalizedString.swift # 国际化支持
│   └── Resources/                # 资源文件
│       └── Localizations/        # 本地化字符串
│           ├── en.lproj/
│           └── zh-Hans.lproj/
├── build_and_deploy.sh           # 构建和部署脚本
├── LICENSE                       # MIT 许可证
├── README.md                     # 项目说明文档（英文）
└── README_zh.md                  # 项目说明文档（中文）
```

## 🔧 开发指南

### 环境要求

- **Xcode**: 15.0 或更高版本
- **Swift**: 5.9 或更高版本
- **macOS**: 13.0 或更高版本

### 构建项目

```bash
# 标准构建（推荐）
./build_and_deploy.sh

# 这将：
# 1. 清理之前的构建文件
# 2. 编译 x86_64 和 arm64 版本
# 3. 合并为 Universal Binary
# 4. 创建应用程序包
# 5. 复制本地化文件
```

### 代码风格

- 遵循 Swift 官方代码规范
- 使用清晰的变量和函数命名
- 为公共 API 添加文档注释
- 保持代码简洁和可维护

### 数据存储

配置数据存储在：

```
~/Library/Application Support/cccfg/
├── configs.json    # 配置数据
└── groups.json     # 分组数据
```

## 🛠️ 技术栈

- **语言**: Swift 5.9+
- **框架**: SwiftUI, AppKit
- **架构**: MVVM 模式
- **数据持久化**: JSON 文件
- **系统集成**: AppleScript (iTerm2 集成)
- **国际化**: 原生本地化支持

## 🐛 故障排除

### 常见问题

**Q: 启动按钮点击后没有反应？**

A: 确保：
1. iTerm2 已正确安装
2. 在"系统设置 > 隐私与安全性 > 辅助功能"中已授权应用权限
3. 检查 iTerm2 是否正确安装（可通过 `ls -la /Applications/iTerm.app` 验证）

**Q: 语言切换不生效？**

A: 确保：
1. 本地化文件已正确复制到应用程序包
2. 重新构建应用：`./build_and_deploy.sh`
3. 重启应用

**Q: 配置数据丢失？**

A: 检查数据文件是否存在：
```bash
ls -la ~/Library/Application\ Support/cccfg/
```

**Q: 编译错误？**

A: 确保：
1. 使用正确的 Swift 版本：`swift --version`
2. 所有依赖文件都存在
3. macOS SDK 路径正确

## 📄 许可证

本项目采用 [MIT 许可证](LICENSE)。

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

- [Anthropic](https://anthropic.com) - Claude API
- [SwiftUI](https://developer.apple.com/xcode/swiftui/) - UI 框架
- [iTerm2](https://iterm2.com/) - 终端模拟器

---

<div align="center">

**[⬆️ 返回顶部](#claude-code-config)**

Made with ❤️ by weiming

</div>

