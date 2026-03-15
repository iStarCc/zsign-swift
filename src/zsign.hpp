//
//  zsign.hpp
//  zsign-swift
//
//  C API bridge for Swift iOS/macOS
//

#ifndef zsign_hpp
#define zsign_hpp

#include <stdio.h>
#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif

bool CheckIfSigned(NSString *filePath);
bool InjectDyLib(NSString *filePath, NSString *dylibPath, bool weakInject);
bool UninstallDylibs(NSString *filePath, NSArray<NSString *> *dylibPathsArray);
NSArray<NSString *> *ListDylibs(NSString *filePath);
bool ChangeDylibPath(NSString *filePath, NSString *oldPath, NSString *newPath);

/// 设置日志语言: "zh" 简体中文, "en" 英文
void ZsignSetLogLocale(const char* locale);

int zsign(
	NSString *app,
	NSString *prov,
	NSString *key,
	NSString *pass,
	NSString *entitlement,
	NSString *bundleid,
	NSString *displayname,
	NSString *bundleversion,
	bool adhoc,
	bool dontGenerateEmbeddedMobileProvision,
	void(^completionHandler)(BOOL success, NSError *error),
	void(^logHandler)(NSString *log)
);

int checkCert(
	NSString *prov,
	NSString *key,
	NSString *pass,
	void(^completionHandler)(int status, NSDate* expirationDate, NSString *error)
);

/// 签名并打包 IPA（支持 IPA 输入或 .app 目录，输出 IPA）
/// - Parameters:
///   - inputPath: 输入路径（.ipa 文件或 .app 目录）
///   - outputPath: 输出 IPA 路径（必填）
///   - 其他参数同 zsign
/// - Returns: 成功返回 0，失败返回 -1
int zsignIPA(
	NSString *inputPath,
	NSString *outputPath,
	NSString *prov,
	NSString *key,
	NSString *pass,
	NSString *entitlement,
	NSString *bundleid,
	NSString *displayname,
	NSString *bundleversion,
	bool adhoc,
	bool excludeprovion,
	int zipLevel,
	void(^completionHandler)(BOOL success, NSError *error),
	void(^logHandler)(NSString *log)
);

#ifdef __cplusplus
}
#endif

#endif /* zsign_hpp */
