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
            name: "minizip",
            path: "src/minizip",
            sources: [
                "ioapi.c",
                "zip.c",
                "unzip.c"
            ],
            publicHeadersPath: ".",
            cSettings: [
                .headerSearchPath(".")
            ],
            linkerSettings: [
                .linkedLibrary("z")
            ]
        ),
        .target(
            name: "Zsign",
            dependencies: [
                .product(name: "OpenSSL", package: "OpenSSL"),
                "minizip"
            ],
            path: "src",
            sources: [
                "archo.cpp",
                "bundle.cpp",
                "macho.cpp",
                "openssl.cpp",
                "openssl_tools.mm",
                "signing.cpp",
                "zsign.mm",
                "common/archive.cpp",
                "common/base64.cpp",
                "common/fs.cpp",
                "common/json.cpp",
                "common/log.cpp",
                "common/l10n.cpp",
                "common/sha.cpp",
                "common/timer.cpp",
                "common/util.cpp"
            ],
            publicHeadersPath: "include",
            cxxSettings: [
                .headerSearchPath("."),
                .headerSearchPath("common"),
                .headerSearchPath("minizip"),
                .unsafeFlags(["-std=c++17"])
            ],
            linkerSettings: [
                .linkedFramework("OpenSSL")
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
