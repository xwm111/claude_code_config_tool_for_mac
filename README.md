# Claude Code Config

<div align="center">

![Version](https://img.shields.io/badge/version-1.1.4-blue.svg)
![Platform](https://img.shields.io/badge/platform-macOS%2013.0+-lightgrey.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)

**Claude Code CLI Configuration Management Tool**

A clean and efficient native macOS application for managing multiple Claude Code CLI configurations.

[中文](README_zh.md) | English

</div>

---

## ✨ Features

- 🎯 **Configuration Management** - Create, edit, delete, and manage multiple Claude Code CLI configurations
- 📁 **Group Organization** - Organize configurations with color-coded groups for easy project management
- 🚀 **One-Click Launch** - Launch configurations directly in iTerm2 without manual command entry
- 📋 **Command Copy** - Quickly copy launch commands to clipboard
- 🌐 **Internationalization** - Full bilingual support (English & Chinese)
- 🎨 **Modern UI** - Native macOS interface built with SwiftUI
- 💾 **Local Storage** - Configuration data securely stored in local JSON files

## 🚀 Quick Start

### Requirements

- **macOS**: 13.0 (Ventura) or later
- **Processor**: Intel or Apple Silicon (Universal Binary)
- **Dependencies**: 
  - [Claude Code CLI](https://github.com/anthropics/claude-code) - Required
  - [iTerm2](https://iterm2.com/) - Required for launch functionality

### Installation

#### Build from Source (Recommended)

```bash
# 1. Clone the repository
git clone <repository-url>
cd claude-code-config-tool

# 2. Build the application
./build_and_deploy.sh

# The app will be generated in the project root: ClaudeCodeConfig.app
```

#### Using Pre-built Version

1. Download the latest `ClaudeCodeConfig.app`
2. Drag the app to your `Applications` folder
3. You may need to allow the app to run in "System Settings > Privacy & Security" on first launch

## 📖 User Guide

### Creating a Configuration

1. Launch the app and click the "Create New Configuration" button
2. Fill in the following information:
   - **Configuration Name**: A recognizable name (e.g., Work Project, Personal Project)
   - **API URL**: Claude API endpoint (default: `https://api.anthropic.com`)
   - **API Key**: Your API key from Anthropic
   - **Working Directory**: Project root directory path
   - **Model Name**: (Optional) Specify Claude model version
3. Optional settings:
   - **Dangerous Mode**: Enable `--dangerously-skip-permissions` parameter
   - **Group**: Select the project group this configuration belongs to
4. Click "Save Configuration" to complete

### Managing Groups

#### Create a Group

1. Click the "+" button next to the group selector
2. Enter group name and select a color
3. Save the group

#### Edit/Delete Group

- Click the edit icon ✏️ in the group list to modify
- Click the delete icon 🗑️ to delete a group (configurations in this group will automatically move to the default group)

### Launching Configurations

The app provides two ways to launch:

#### Method 1: Direct iTerm2 Launch

1. Find the target configuration in the configuration list
2. Click the "Launch" button
3. The app will automatically open iTerm2 and execute the launch command in a new tab

#### Method 2: Copy Command

1. Click the "Copy Command" button on a configuration
2. The launch command is copied to clipboard
3. Paste and execute in your terminal

## 🏗️ Project Structure

```
claude-code-config-tool/
├── src/                          # Source code directory
│   ├── main.swift                # Application entry point and AppDelegate
│   ├── Models/                   # Data models
│   │   ├── Config.swift          # Configuration model
│   │   └── ConfigGroup.swift     # Group model
│   ├── Views/                    # SwiftUI views
│   │   ├── ContentView.swift     # Main view
│   │   ├── ConfigEditView.swift  # Configuration edit view
│   │   ├── SimpleGroupEditView.swift  # Group edit view
│   │   ├── LanguageSwitcher.swift    # Language switcher
│   │   └── CyberpunkToast.swift      # Toast notification component
│   ├── Services/                 # Business logic layer
│   │   ├── ConfigManager.swift   # Configuration management service
│   │   ├── GroupManager.swift    # Group management service
│   │   └── CLILauncher.swift    # CLI launch service
│   ├── Utilities/                # Utility classes
│   │   ├── Constants.swift       # Application constants
│   │   ├── WindowManager.swift   # Window management
│   │   └── LocalizedString.swift # Internationalization support
│   └── Resources/                # Resource files
│       └── Localizations/        # Localized strings
│           ├── en.lproj/
│           └── zh-Hans.lproj/
├── build_and_deploy.sh           # Build and deployment script
├── LICENSE                       # MIT License
├── README.md                     # Project documentation (English)
└── README_zh.md                  # Project documentation (Chinese)
```

## 🔧 Development Guide

### Requirements

- **Xcode**: 15.0 or later
- **Swift**: 5.9 or later
- **macOS**: 13.0 or later

### Building the Project

```bash
# Standard build (recommended)
./build_and_deploy.sh

# This will:
# 1. Clean previous build files
# 2. Compile x86_64 and arm64 versions
# 3. Merge into Universal Binary
# 4. Create application bundle
# 5. Copy localization files
```

### Code Style

- Follow Swift official code conventions
- Use clear variable and function naming
- Add documentation comments for public APIs
- Keep code concise and maintainable

### Data Storage

Configuration data is stored at:

```
~/Library/Application Support/cccfg/
├── configs.json    # Configuration data
└── groups.json     # Group data
```

## 🛠️ Tech Stack

- **Language**: Swift 5.9+
- **Framework**: SwiftUI, AppKit
- **Architecture**: MVVM pattern
- **Data Persistence**: JSON files
- **System Integration**: AppleScript (iTerm2 integration)
- **Internationalization**: Native localization support

## 🐛 Troubleshooting

### Common Issues

**Q: Launch button doesn't work after clicking?**

A: Make sure:
1. iTerm2 is properly installed
2. The app has been granted permissions in "System Settings > Privacy & Security > Accessibility"
3. Verify iTerm2 installation with `ls -la /Applications/iTerm.app`

**Q: Language switching doesn't work?**

A: Ensure:
1. Localization files are correctly copied to the application bundle
2. Rebuild the app: `./build_and_deploy.sh`
3. Restart the app

**Q: Configuration data lost?**

A: Check if data files exist:
```bash
ls -la ~/Library/Application\ Support/cccfg/
```

**Q: Build errors?**

A: Ensure:
1. Using correct Swift version: `swift --version`
2. All dependency files exist
3. macOS SDK path is correct

## 📄 License

This project is licensed under the [MIT License](LICENSE).

## 👨‍💻 Developer

- **Developer**: weiming
- **Email**: swimming.xwm@gmail.com
- **Copyright**: Copyright © 2025 weiming. All rights reserved.

## 🤝 Contributing

Issues and Pull Requests are welcome!

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 🙏 Acknowledgments

- [Anthropic](https://anthropic.com) - Claude API
- [SwiftUI](https://developer.apple.com/xcode/swiftui/) - UI framework
- [iTerm2](https://iterm2.com/) - Terminal emulator

---

<div align="center">

**[⬆ Back to Top](#claude-code-config)**

Made with ❤️ by weiming

</div>
