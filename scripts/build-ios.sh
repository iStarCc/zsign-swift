#!/bin/bash
# zsign-swift iOS 构建脚本
# 使用 Xcode 的 iOS SDK 构建（需已安装 Xcode）

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"

if [ ! -d "$DEVELOPER_DIR" ]; then
    echo "错误: 未找到 Xcode，请安装 Xcode 或设置 DEVELOPER_DIR"
    exit 1
fi

SDK_PATH=$(DEVELOPER_DIR="$DEVELOPER_DIR" xcrun --sdk iphonesimulator --show-sdk-path 2>/dev/null || true)
if [ -z "$SDK_PATH" ]; then
    echo "错误: 无法获取 iOS 模拟器 SDK 路径"
    exit 1
fi

echo ">>> 构建 zsign-swift (iOS 模拟器)"
echo "    SDK: $SDK_PATH"
echo ""

cd "$PROJECT_DIR"
DEVELOPER_DIR="$DEVELOPER_DIR" swift build \
    -Xswiftc "-sdk" -Xswiftc "$SDK_PATH" \
    -Xswiftc "-target" -Xswiftc "arm64-apple-ios12.0-simulator"

echo ""
echo ">>> iOS 构建成功!"
