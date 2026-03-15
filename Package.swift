// swift-tools-version: 5.8
// zsign-swift - 基于 zsign 新代码的 Swift 封装，支持 iOS 和 macOS

import PackageDescription

let package = Package(
    name: "zsign-swift",
    platforms: [
        .iOS(.v12),
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "Zsign",
            targets: ["Zsign"]
        ),
        .library(
            name: "ZsignSwift",
            targets: ["ZsignSwift"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/krzyzanowskim/OpenSSL", from: "3.3.3001")
    ],
    targets: [
        .target(
            name: "Zsign",
            dependencies: [
                .product(name: "OpenSSL", package: "OpenSSL")
            ],
            path: "src",
            exclude: [
                "common/archive.cpp",
            ],
            sources: [
                "archo.cpp",
                "bundle.cpp",
                "macho.cpp",
                "openssl.cpp",
                "openssl_tools.mm",
                "signing.cpp",
                "zsign.mm",
                "common/base64.cpp",
                "common/fs.cpp",
                "common/json.cpp",
                "common/log.cpp",
                "common/sha.cpp",
                "common/timer.cpp",
                "common/util.cpp"
            ],
            publicHeadersPath: "include",
            cxxSettings: [
                .headerSearchPath("."),
                .headerSearchPath("common"),
                .unsafeFlags(["-std=c++17"])
            ],
            linkerSettings: [
                .linkedFramework("OpenSSL"),
            ]
        ),
        .target(
            name: "ZsignSwift",
            dependencies: [
                "Zsign"
            ],
            path: "Sources/ZsignSwift",
            sources: [
                "Zsign.swift"
            ]
        )
    ],
    cxxLanguageStandard: .cxx17
)
