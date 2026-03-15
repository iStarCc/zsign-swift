# zsign-swift

基于 [zsign](https://github.com/zhlynn/zsign) 新代码重构的 Swift 封装，支持 **iOS** 和 **macOS** 项目。

## 功能特性

- **应用签名**：对 .app 应用包进行代码签名
- **检查签名**：验证 Mach-O 文件是否已正确签名
- **Dylib 注入**：向可执行文件注入动态库加载命令
- **Dylib 管理**：列出、移除、修改 dylib 路径
- **证书校验**：检查证书吊销状态（OCSP）

## 平台支持

| 平台 | 最低版本 |
|------|----------|
| iOS | 12.0 |
| macOS | 10.15 |

## 构建

### macOS
```bash
swift build
```

### iOS
需要安装完整 Xcode（非仅 Command Line Tools）。构建命令：

```bash
# 方式 1：使用构建脚本
./scripts/build-ios.sh

# 方式 2：手动指定 Xcode 路径
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build \
  -Xswiftc "-sdk" -Xswiftc "$(xcrun --sdk iphonesimulator --show-sdk-path)" \
  -Xswiftc "-target" -Xswiftc "arm64-apple-ios12.0-simulator"
```

或在 Xcode 中：**File → Open** 打开 `zsign-swift` 文件夹，选择 **iPhone Simulator** 作为目标后构建。

## 安装

在 `Package.swift` 中添加依赖：

```swift
dependencies: [
    .package(path: "../zsign-swift")  // 或使用 git URL
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            .product(name: "ZsignSwift", package: "zsign-swift")
        ]
    )
]
```

## 使用示例

```swift
import ZsignSwift

// 检查是否已签名
let isSigned = Zsign.checkSigned(appExecutable: "/path/to/executable")

// 注入 dylib
Zsign.injectDyLib(appExecutable: "/path/to/app", with: "@rpath/MyFramework.framework/MyFramework", weak: true)

// 移除 dylib
Zsign.removeDylibs(appExecutable: "/path/to/app", using: ["@rpath/OldLib.dylib"])

// 列出 dylib
let dylibs = Zsign.listDylibs(appExecutable: "/path/to/app")

// 修改 dylib 路径
Zsign.changeDylibPath(appExecutable: "/path/to/app", for: "/old/path.dylib", with: "@rpath/new.dylib")

// 签名应用包
Zsign.sign(
    appPath: "/path/to/App.app",
    provisionPath: "/path/to/profile.mobileprovision",
    p12Path: "/path/to/cert.p12",
    p12Password: "password",
    entitlementsPath: "/path/to/entitlements.plist",
    customIdentifier: "com.example.app",
    customName: "My App",
    customVersion: "1.0",
    adhoc: false,
    removeProvision: false
) { success, error in
    if success {
        print("签名成功")
    } else {
        print("签名失败: \(error?.localizedDescription ?? "")")
    }
}

// 检查证书吊销状态
Zsign.checkRevokage(
    provisionPath: "/path/to/profile.mobileprovision",
    p12Path: "/path/to/cert.p12",
    p12Password: "password"
) { status, expirationDate, error in
    // status: 0=有效, 1=已吊销, 2=已过期
    print("证书状态: \(status)")
}
```

## 项目结构

```
zsign-swift/
├── Package.swift
├── README.md
├── Sources/
│   └── ZsignSwift/
│       └── Zsign.swift      # Swift 封装层
└── src/
    ├── include/
    │   └── Zsign.h          # 公共 C 头文件
    ├── zsign.hpp            # C API 声明
    ├── zsign.mm             # Objective-C++ 桥接层
    ├── bundle.cpp/h         # 应用包签名
    ├── macho.cpp/h          # Mach-O 处理
    ├── archo.cpp/h          # 架构处理
    ├── openssl.cpp/h        # 证书与签名
    ├── signing.cpp/h        # 签名逻辑
    ├── openssl_tools.mm     # P12 工具
    └── common/              # 公共工具
```

## 与 Zsign-Package 的差异

- **核心代码**：基于 zsign 新代码（v0.9.6+），包含 `arrRemoveDylibNames`、`bRemoveProvision` 等新特性
- **Bundle 能力**：支持 `m_bEnableDocuments`、`m_strMinVersion`、`m_bRemoveExtensions` 等配置
- **API 兼容**：Swift API 与 Zsign-Package 保持兼容，便于迁移

## 依赖

- [OpenSSL](https://github.com/krzyzanowskim/OpenSSL) (krzyzanowskim/OpenSSL)

## License

遵循 zsign 原项目许可。
