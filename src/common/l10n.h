//
//  l10n.h
//  zsign-swift
//
//  日志国际化
//

#pragma once

#include "common.h"
#include "log_keys.h"
#include <map>
#include <string>

class ZL10n
{
public:
	/// 支持的语言: "zh" 简体中文, "en" 英文
	static void SetLocale(const char* locale);
	static const char* GetLocale();
	
	/// 获取本地化字符串，key 见 log_keys.h
	static const char* Get(const char* key);
	
	/// 获取带占位符的格式串，用于 PrintV
	static const char* GetFmt(const char* key);

private:
	static string g_locale;
	static map<string, map<string, string>> g_strings;
	static void InitStrings();
};
