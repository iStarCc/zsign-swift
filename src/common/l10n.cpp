//
//  l10n.cpp
//  zsign-swift
//

#include "l10n.h"

using namespace ZL10nKeys;

string ZL10n::g_locale = "zh";
map<string, map<string, string>> ZL10n::g_strings;

void ZL10n::SetLocale(const char* locale) {
	if (locale && strlen(locale) >= 2) {
		g_locale = locale;
		if (g_locale != "zh" && g_locale != "en") {
			g_locale = "zh";
		}
	}
}

const char* ZL10n::GetLocale() {
	return g_locale.c_str();
}

void ZL10n::InitStrings() {
	if (!g_strings.empty()) return;
	
	// 简体中文
	map<string, string>& zh = g_strings["zh"];
	zh[INVALID_PATH] = ">>> 路径无效! %s\n";
	zh[INVALID_INPUT_PATH] = ">>> 输入路径无效! %s\n";
	zh[OUTPUT_PATH_REQUIRED] = ">>> signIPA 需要指定输出路径。\n";
	zh[SIGNING] = ">>> 签名中:\t%s %s\n";
	zh[SIGNED_FMT] = ">>> 签名完成! %s";
	zh[SIGNED_OK] = "OK";
	zh[SIGNED_FAILED] = "失败";
	zh[DONE] = ">>> 完成。";
	zh[UNZIP] = ">>> 解压:\t%s (%s) -> ... \n";
	zh[UNZIP_FAILED] = ">>> 解压失败!\n";
	zh[UNZIP_OK] = ">>> 解压完成!";
	zh[ARCHIVING] = ">>> 打包:\t%s ... \n";
	zh[ARCHIVE_OK] = ">>> 打包完成! (%s)";
	zh[ARCHIVE_FAILED] = ">>> 打包失败!\n";
	zh[FAILED_CREATE_PAYLOAD] = ">>> 创建 Payload 目录失败!\n";
	zh[FAILED_COPY_APP] = ">>> 复制应用到 Payload 失败: %s\n";
	zh[REMOVED_EMBEDDED_PROVISION] = ">>> 已移除 embedded.mobileprovision\n";
	zh[SIGN_FILE] = ">>> 签名文件: \t%s\n";
	zh[SKIP_NON_MACHO] = ">>> 警告: 跳过非 Mach-O 文件: \t%s\n";
	zh[CANT_GET_BUNDLE_INFO] = ">>> 无法从 Info.plist 获取 BundleID 或 BundleExecute 或 SHASum! %s\n";
	zh[CANT_PARSE_EXECUTABLE] = ">>> 无法解析可执行文件! %s\n";
	zh[CREATE_CODERESOURCES_FAILED] = ">>> 创建 CodeResources 失败! %s\n";
	zh[CANT_GET_SHASUM] = ">>> 无法获取变更文件 SHASum! %s";
	zh[WRITING_CODERESOURCES_FAILED] = "\t写入 CodeResources 失败! %s\n";
	zh[CANT_WRITE_PROVISION] = ">>> 无法写入 embedded.mobileprovision!\n";
	zh[CANT_FIND_PLUGIN_INFO] = ">>> 找不到插件的 Info.plist! %s\n";
	zh[BUNDLE_ID] = ">>> BundleId: \t%s -> %s\n";
	zh[BUNDLE_ID_VALUE] = ">>> BundleId: \t%s\n";
	zh[BUNDLE_ID_PLUGIN] = ">>> BundleId: \t%s -> %s, Plugin\n";
	zh[BUNDLE_ID_WK] = ">>> BundleId: \t%s -> %s, Plugin-WKCompanionAppBundleIdentifier\n";
	zh[BUNDLE_ID_EXT] = ">>> BundleId: \t%s -> %s, NSExtension-NSExtensionAttributes-WKAppBundleIdentifier\n";
	zh[CANT_FIND_APP_INFO] = ">>> 找不到应用的 Info.plist! %s\n";
	zh[BUNDLE_NAME] = ">>> BundleName: %s -> %s\n";
	zh[BUNDLE_VERSION] = ">>> BundleVersion: %s -> %s\n";
	zh[ENABLED_DOCUMENTS] = ">>> 已启用文档支持\n";
	zh[MIN_OS_VERSION] = ">>> MinimumOSVersion: %s -> %s\n";
	zh[REMOVED] = ">>> 已移除 %s\n";
	zh[REMOVED_UI_DEVICES] = ">>> 已移除 UISupportedDevices\n";
	zh[CANT_FIND_APP_FOLDER] = ">>> 找不到应用目录! %s\n";
	zh[CANT_GET_INFO_PLIST] = ">>> 无法从 Info.plist 获取 BundleID、BundleVersion 或 BundleExecute! %s\n";
	zh[SIGN_FOLDER] = ">>> SignFolder: %s, (%s)\n";
	zh[SIGNING_APP] = ">>> 签名中: \t%s ...\n";
	zh[APP_NAME] = ">>> AppName: \t%s\n";
	zh[VERSION] = ">>> Version: \t%s\n";
	zh[TEAM_ID] = ">>> TeamId: \t%s\n";
	zh[SUBJECT_CN] = ">>> SubjectCN: \t%s\n";
	zh[READ_CACHE] = ">>> ReadCache: \t%s\n";
	zh[CACHE_YES] = "YES";
	zh[CACHE_NO] = "NO";
	zh[ADHOC] = " (Ad-hoc)";
	
	// English
	map<string, string>& en = g_strings["en"];
	en[INVALID_PATH] = ">>> Invalid path! %s\n";
	en[INVALID_INPUT_PATH] = ">>> Invalid input path! %s\n";
	en[OUTPUT_PATH_REQUIRED] = ">>> Output path is required for signIPA.\n";
	en[SIGNING] = ">>> Signing:\t%s %s\n";
	en[SIGNED_FMT] = ">>> Signed %s!";
	en[SIGNED_OK] = "OK";
	en[SIGNED_FAILED] = "Failed";
	en[DONE] = ">>> Done.";
	en[UNZIP] = ">>> Unzip:\t%s (%s) -> ... \n";
	en[UNZIP_FAILED] = ">>> Unzip failed!\n";
	en[UNZIP_OK] = ">>> Unzip OK!";
	en[ARCHIVING] = ">>> Archiving: \t%s ... \n";
	en[ARCHIVE_OK] = ">>> Archive OK! (%s)";
	en[ARCHIVE_FAILED] = ">>> Archive failed!\n";
	en[FAILED_CREATE_PAYLOAD] = ">>> Failed to create Payload folder!\n";
	en[FAILED_COPY_APP] = ">>> Failed to copy app to Payload: %s\n";
	en[REMOVED_EMBEDDED_PROVISION] = ">>> Removed embedded.mobileprovision\n";
	en[SIGN_FILE] = ">>> SignFile: \t%s\n";
	en[SKIP_NON_MACHO] = ">>> Warning: Skipping non-Mach-O file: \t%s\n";
	en[CANT_GET_BUNDLE_INFO] = ">>> Can't get BundleID or BundleExecute or Info.plist SHASum! %s\n";
	en[CANT_PARSE_EXECUTABLE] = ">>> Can't parse BundleExecute file! %s\n";
	en[CREATE_CODERESOURCES_FAILED] = ">>> Create CodeResources failed! %s\n";
	en[CANT_GET_SHASUM] = ">>> Can't get changed file SHASum! %s";
	en[WRITING_CODERESOURCES_FAILED] = "\tWriting CodeResources failed! %s\n";
	en[CANT_WRITE_PROVISION] = ">>> Can't write embedded.mobileprovision!\n";
	en[CANT_FIND_PLUGIN_INFO] = ">>> Can't find Plugin's Info.plist! %s\n";
	en[BUNDLE_ID] = ">>> BundleId: \t%s -> %s\n";
	en[BUNDLE_ID_VALUE] = ">>> BundleId: \t%s\n";
	en[BUNDLE_ID_PLUGIN] = ">>> BundleId: \t%s -> %s, Plugin\n";
	en[BUNDLE_ID_WK] = ">>> BundleId: \t%s -> %s, Plugin-WKCompanionAppBundleIdentifier\n";
	en[BUNDLE_ID_EXT] = ">>> BundleId: \t%s -> %s, NSExtension-NSExtensionAttributes-WKAppBundleIdentifier\n";
	en[CANT_FIND_APP_INFO] = ">>> Can't find app's Info.plist! %s\n";
	en[BUNDLE_NAME] = ">>> BundleName: %s -> %s\n";
	en[BUNDLE_VERSION] = ">>> BundleVersion: %s -> %s\n";
	en[ENABLED_DOCUMENTS] = ">>> Enabled documents support\n";
	en[MIN_OS_VERSION] = ">>> MinimumOSVersion: %s -> %s\n";
	en[REMOVED] = ">>> Removed %s\n";
	en[REMOVED_UI_DEVICES] = ">>> Removed UISupportedDevices\n";
	en[CANT_FIND_APP_FOLDER] = ">>> Can't find app folder! %s\n";
	en[CANT_GET_INFO_PLIST] = ">>> Can't get BundleID, BundleVersion, or BundleExecute in Info.plist! %s\n";
	en[SIGN_FOLDER] = ">>> SignFolder: %s, (%s)\n";
	en[SIGNING_APP] = ">>> Signing: \t%s ...\n";
	en[APP_NAME] = ">>> AppName: \t%s\n";
	en[VERSION] = ">>> Version: \t%s\n";
	en[TEAM_ID] = ">>> TeamId: \t%s\n";
	en[SUBJECT_CN] = ">>> SubjectCN: \t%s\n";
	en[READ_CACHE] = ">>> ReadCache: \t%s\n";
	en[CACHE_YES] = "YES";
	en[CACHE_NO] = "NO";
	en[ADHOC] = " (Ad-hoc)";
}

const char* ZL10n::Get(const char* key) {
	return GetFmt(key);
}

const char* ZL10n::GetFmt(const char* key) {
	InitStrings();
	auto it = g_strings.find(g_locale);
	if (it == g_strings.end()) it = g_strings.find("zh");
	if (it == g_strings.end()) return key;
	auto kit = it->second.find(key);
	if (kit == it->second.end()) return key;
	return kit->second.c_str();
}
