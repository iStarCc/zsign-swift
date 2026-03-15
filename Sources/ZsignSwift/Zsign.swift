//
//  Zsign.swift
//  zsign-swift
//
//  Swift 封装层 - 支持 iOS 和 macOS 项目
//

import Zsign

public enum Zsign {
    /// 检查 Mach-O 文件是否已正确签名
    /// - Parameter appExecutable: 可执行文件路径
    /// - Returns: 已签名返回 true
    public static func checkSigned(appExecutable: String) -> Bool {
        CheckIfSigned(appExecutable)
    }

    /// 向可执行文件注入加载命令
    /// - Parameters:
    ///   - appExecutable: 可执行文件路径
    ///   - path: 加载命令路径（如 `@rpath/CydiaSubstrate.framework`）
    ///   - weak: 是否弱注入
    /// - Returns: 成功返回 true
    public static func injectDyLib(appExecutable: String, with path: String, weak: Bool = true) -> Bool {
        InjectDyLib(appExecutable, path, weak)
    }

    /// 从可执行文件移除加载命令
    /// - Parameters:
    ///   - appExecutable: 可执行文件路径
    ///   - dylibs: 要移除的加载命令列表
    /// - Returns: 成功返回 true
    public static func removeDylibs(appExecutable: String, using dylibs: [String]) -> Bool {
        UninstallDylibs(appExecutable, dylibs)
    }

    /// 列出可执行文件中的加载命令
    /// - Parameter appExecutable: 可执行文件路径
    /// - Returns: 加载命令字符串数组
    public static func listDylibs(appExecutable: String) -> [String] {
        ListDylibs(appExecutable)
    }

    /// 匹配并替换可执行文件中的加载命令
    /// - Parameters:
    ///   - appExecutable: 可执行文件路径
    ///   - old: 旧路径
    ///   - new: 新路径
    /// - Returns: 成功返回 true
    public static func changeDylibPath(appExecutable: String, for old: String, with new: String) -> Bool {
        ChangeDylibPath(appExecutable, old, new)
    }

    /// 使用 Zsign 对应用包进行签名
    /// - Parameters:
    ///   - appPath: 应用包路径
    ///   - provisionPath: 描述文件路径
    ///   - p12Path: P12 证书路径
    ///   - p12Password: P12 密码
    ///   - entitlementsPath: 权限文件路径
    ///   - customIdentifier: 自定义 Bundle ID
    ///   - customName: 自定义显示名称
    ///   - customVersion: 自定义版本号
    ///   - adhoc: 是否使用 Ad-hoc 签名
    ///   - removeProvision: 是否在签名后移除 embedded.mobileprovision
    ///   - completion: 完成回调 (success, error)
    /// - Returns: 调用成功返回 true
    public static func sign(
        appPath: String = "",
        provisionPath: String = "",
        p12Path: String = "",
        p12Password: String = "",
        entitlementsPath: String = "",
        customIdentifier: String = "",
        customName: String = "",
        customVersion: String = "",
        adhoc: Bool = false,
        removeProvision: Bool = false,
        completion: ((Bool, Error?) -> Void)? = nil
    ) -> Bool {
        if zsign(
            appPath,
            provisionPath,
            p12Path,
            p12Password,
            entitlementsPath,
            customIdentifier,
            customName,
            customVersion,
            adhoc,
            removeProvision,
            completion.map { callback in
                { success, error in
                    callback(success, error)
                }
            }
        ) != 0 {
            return false
        }
        return true
    }

    /// 检查证书吊销状态
    /// - Parameters:
    ///   - provisionPath: 描述文件路径
    ///   - p12Path: P12 证书路径
    ///   - p12Password: P12 密码
    ///   - completionHandler: 回调 (status: 0=有效, 1=已吊销, 2=已过期, expirationDate, error)
    public static func checkRevokage(
        provisionPath: String = "",
        p12Path: String = "",
        p12Password: String = "",
        completionHandler: @escaping (Int32, Date?, String?) -> Void
    ) {
        checkCert(
            provisionPath,
            p12Path,
            p12Password
        ) { status, expirationDate, error in
            completionHandler(status, expirationDate, error)
        }
    }
}
