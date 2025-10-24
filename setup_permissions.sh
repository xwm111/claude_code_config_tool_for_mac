#!/bin/bash

echo "=== Claude Code Config 权限设置脚本 ==="
echo ""

# 检查应用是否存在
APP_PATH="$HOME/Applications/CCCConfig.app"
if [ ! -d "$APP_PATH" ]; then
    echo "❌ 错误: 应用程序未找到在 $APP_PATH"
    exit 1
fi

echo "✅ 找到应用程序: $APP_PATH"

# 尝试使用 tccutil 重置权限
echo ""
echo "🔄 重置应用程序权限..."
sudo tccutil reset AppleEvents com.claudecode.config 2>/dev/null || echo "注意: 无法重置 AppleEvents 权限"

echo ""
echo "📋 需要手动配置的权限:"
echo "1. 打开 系统设置 > 隐私与安全性"
echo "2. 点击 自动化"
echo "3. 找到 'CCCConfig' 或 'Claude Code Config'"
echo "4. 允许它控制 iTerm"
echo ""
echo "📋 备选方案:"
echo "1. 打开 系统设置 > 隐私与安全性 > 辅助功能"
echo "2. 找到并启用 'CCCConfig'"
echo ""
echo "完成后，请重新启动应用程序。"

# 检查 iTerm 是否安装
ITERM_PATH="/Applications/iTerm.app"
ITERM2_PATH="/Applications/iTerm2.app"

if [ -d "$ITERM_PATH" ] || [ -d "$ITERM2_PATH" ]; then
    echo ""
    echo "✅ iTerm 已安装"
else
    echo ""
    echo "⚠️  警告: 未找到 iTerm，请先安装 iTerm2"
    echo "下载地址: https://iterm2.com"
fi

echo ""
echo "权限设置完成！现在可以尝试启动应用程序。"