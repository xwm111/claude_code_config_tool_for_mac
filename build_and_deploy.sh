#!/bin/bash

# Claude Code Config 应用构建和部署脚本
# 这个脚本会编译Swift代码并创建macOS应用程序包

set -e  # 遇到错误立即退出

echo "🚀 开始构建 Claude Code Config 应用..."

# 定义变量
APP_NAME="ClaudeCodeConfig"
BUNDLE_ID="com.claudecode.config"
VERSION="1.1.4"
SOURCE_FILE="src/main.swift"
TEMP_BUILD_DIR="build"
APP_DIR="Applications"

# 清理之前的构建
echo "🧹 清理之前的构建文件..."
rm -rf "$TEMP_BUILD_DIR"
rm -rf "${APP_NAME}.app"

# 创建构建目录
echo "📁 创建构建目录..."
mkdir -p "$TEMP_BUILD_DIR"

# 编译Swift代码为可执行文件
echo "🔨 编译Swift代码..."
echo "   源文件: $SOURCE_FILE"
echo "   目标架构: x86_64 arm64 (Universal Binary)"

# 查找所有Swift文件
SWIFT_FILES=$(find src -name "*.swift" -type f | tr '\n' ' ')
echo "   包含文件: $SWIFT_FILES"

# 创建Universal Binary (支持Intel和Apple Silicon)
echo "   编译Intel x86_64版本..."
swiftc -target x86_64-apple-macos13.0 -sdk $(xcrun --show-sdk-path --sdk macosx) \
    -parse-as-library -O $SWIFT_FILES -o "$TEMP_BUILD_DIR/${APP_NAME}_x86_64" \
    -suppress-warnings

echo "   编译Apple Silicon arm64版本..."
swiftc -target arm64-apple-macos13.0 -sdk $(xcrun --show-sdk-path --sdk macosx) \
    -parse-as-library -O $SWIFT_FILES -o "$TEMP_BUILD_DIR/${APP_NAME}_arm64" \
    -suppress-warnings

echo "   合并为Universal Binary..."
lipo -create \
    "$TEMP_BUILD_DIR/${APP_NAME}_x86_64" \
    "$TEMP_BUILD_DIR/${APP_NAME}_arm64" \
    -output "$TEMP_BUILD_DIR/$APP_NAME"

# 验证二进制文件
echo "✅ 验证Universal Binary..."
file "$TEMP_BUILD_DIR/$APP_NAME"
lipo -info "$TEMP_BUILD_DIR/$APP_NAME"

# 创建应用程序包结构
echo "📦 创建应用程序包结构..."
mkdir -p "${APP_NAME}.app/Contents/MacOS"
mkdir -p "${APP_NAME}.app/Contents/Resources"

# 复制可执行文件到应用程序包
echo "📋 复制可执行文件..."
cp "$TEMP_BUILD_DIR/$APP_NAME" "${APP_NAME}.app/Contents/MacOS/"
chmod +x "${APP_NAME}.app/Contents/MacOS/$APP_NAME"

# 创建Info.plist
echo "📄 创建Info.plist..."
cat > "${APP_NAME}.app/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>$BUNDLE_ID</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundleDisplayName</key>
    <string>Claude Code Config</string>
    <key>CFBundleVersion</key>
    <string>$VERSION</string>
    <key>CFBundleShortVersionString</key>
    <string>$VERSION</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleSignature</key>
    <string>????</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>LSUIElement</key>
    <false/>
    <key>NSSupportsAutomaticGraphicsSwitching</key>
    <true/>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>NSRequiresAquaSystemAppearance</key>
    <false/>
    <key>NSAppleEventsUsageDescription</key>
    <string>Claude Code Config 需要 AppleScript 权限来启动 iTerm2 并配置开发环境，包括设置工作目录和启动 Claude CLI。</string>
    <key>NSSystemAdministrationUsageDescription</key>
    <string>Claude Code Config 需要系统管理权限来检查和配置开发环境，确保 iTerm2 和 Claude CLI 正确安装。</string>
    <key>NSDocumentsFolderUsageDescription</key>
    <string>Claude Code Config 需要访问文档文件夹来读取和写入项目配置文件。</string>
    <key>LSApplicationCategoryType</key>
    <string>public.app-category.developer-tools</string>
    <key>CFBundleGetInfoString</key>
    <string>Claude Code Config v$VERSION - Claude Code CLI 配置管理工具</string>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2025 weiming. All rights reserved.</string>
    <key>CFBundleDeveloper</key>
    <string>weiming</string>
    <key>CFBundleEmail</key>
    <string>swimming.xwm@gmail.com</string>
</dict>
</plist>
EOF

# 清理临时文件
echo "🧹 清理临时文件..."
rm -rf "$TEMP_BUILD_DIR"

# 设置应用程序图标（如果有的话）
if [ -f "AppIcon.icns" ]; then
    echo "🎨 添加应用程序图标..."
    mkdir -p "${APP_NAME}.app/Contents/Resources"
    cp "AppIcon.icns" "${APP_NAME}.app/Contents/Resources/AppIcon.icns"

    # 更新Info.plist以包含图标
    /usr/libexec/PlistBuddy -c "Add :CFBundleIconFile string AppIcon" "${APP_NAME}.app/Contents/Info.plist" 2>/dev/null || true
fi

echo "✅ 应用程序构建完成!"
echo "   应用程序包: ${APP_NAME}.app"
echo "   版本: $VERSION"
echo "   Bundle ID: $BUNDLE_ID"

# 检查是否需要部署到系统Applications目录
if [ "$1" = "--deploy" ]; then
    echo ""
    echo "🚀 部署应用程序到系统Applications目录..."

    # 检查权限
    if [ ! -w "/Applications" ]; then
        echo "⚠️  需要管理员权限来复制到 /Applications 目录"
        echo "   使用 sudo 运行此脚本："
        echo "   sudo $0 --deploy"
        exit 1
    fi

    # 复制到Applications目录
    echo "📋 复制应用程序到 /Applications..."
    cp -R "${APP_NAME}.app" "/Applications/"

    echo "✅ 应用程序已部署到 /Applications/${APP_NAME}.app"
    echo ""
    echo "🎉 部署完成!"
    echo "   你可以在启动台中找到 'Claude Code Config'"
    echo "   或者在终端中运行: open '/Applications/${APP_NAME}.app'"
    echo ""
    echo "⚠️  首次运行时，系统可能会提示需要授权："
    echo "   - AppleScript 权限（用于控制 iTerm2）"
    echo "   - 文件访问权限（用于读取配置文件）"
    echo ""
    echo "📚 使用说明："
    echo "   1. 打开应用程序"
    echo "   2. 点击 '添加配置' 创建新的 Claude CLI 配置"
    echo "   3. 填写 API URL、API Key、工作目录等信息"
    echo "   4. 可选择启用危险模式（添加 --dangerously-skip-permissions 参数）"
    echo "   5. 点击 '启动' 按钮启动配置的开发环境"
fi

echo ""
echo "🎯 构建脚本执行完成!"
echo "   应用程序包位置: $(pwd)/${APP_NAME}.app"