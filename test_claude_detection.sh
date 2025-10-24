#!/bin/bash

echo "=== 测试 Claude CLI 检测 ==="
echo ""

# 测试路径
CLAUDE_PATH="/Users/weimingxu/.nvm/versions/node/v22.14.0/bin/claude"

echo "1. 测试文件存在性 (FileManager 方式):"
if [ -f "$CLAUDE_PATH" ]; then
    echo "✅ 文件存在: $CLAUDE_PATH"
else
    echo "❌ 文件不存在: $CLAUDE_PATH"
fi

echo ""
echo "2. 测试符号链接解析:"
if [ -L "$CLAUDE_PATH" ]; then
    echo "✅ 是符号链接"
    REAL_PATH=$(readlink "$CLAUDE_PATH")
    echo "   指向: $REAL_PATH"

    # 解析相对路径
    FULL_PATH=$(dirname "$CLAUDE_PATH")/$REAL_PATH
    echo "   完整路径: $FULL_PATH"

    if [ -f "$FULL_PATH" ]; then
        echo "✅ 目标文件存在"
    else
        echo "❌ 目标文件不存在"
    fi
else
    echo "❌ 不是符号链接"
fi

echo ""
echo "3. 测试直接执行:"
if $CLAUDE_PATH --version >/dev/null 2>&1; then
    VERSION=$($CLAUDE_PATH --version)
    echo "✅ 可以直接执行"
    echo "   版本: $VERSION"
else
    echo "❌ 无法直接执行"
fi

echo ""
echo "4. 测试 Process 执行方式:"
echo "执行命令: Process.executableURL = $CLAUDE_PATH"
echo "参数: [--version]"