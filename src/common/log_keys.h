//
//  log_keys.h
//  zsign-swift
//
//  日志消息键，用于 L10n 国际化
//

#ifndef log_keys_h
#define log_keys_h

namespace ZL10nKeys {

// zsign.mm - 签名流程
constexpr const char* INVALID_PATH = "invalid_path";
constexpr const char* INVALID_INPUT_PATH = "invalid_input_path";
constexpr const char* OUTPUT_PATH_REQUIRED = "output_path_required";
constexpr const char* SIGNING = "signing";
constexpr const char* SIGNED_FMT = "signed_fmt";
constexpr const char* SIGNED_OK = "signed_ok";
constexpr const char* SIGNED_FAILED = "signed_failed";
constexpr const char* DONE = "done";
constexpr const char* UNZIP = "unzip";
constexpr const char* UNZIP_FAILED = "unzip_failed";
constexpr const char* UNZIP_OK = "unzip_ok";
constexpr const char* ARCHIVING = "archiving";
constexpr const char* ARCHIVE_OK = "archive_ok";
constexpr const char* ARCHIVE_FAILED = "archive_failed";
constexpr const char* FAILED_CREATE_PAYLOAD = "failed_create_payload";
constexpr const char* FAILED_COPY_APP = "failed_copy_app";

// bundle.cpp - 签名详情
constexpr const char* REMOVED_EMBEDDED_PROVISION = "removed_embedded_provision";
constexpr const char* SIGN_FILE = "sign_file";
constexpr const char* SKIP_NON_MACHO = "skip_non_macho";
constexpr const char* CANT_GET_BUNDLE_INFO = "cant_get_bundle_info";
constexpr const char* CANT_PARSE_EXECUTABLE = "cant_parse_executable";
constexpr const char* CREATE_CODERESOURCES_FAILED = "create_coderesources_failed";
constexpr const char* CANT_GET_SHASUM = "cant_get_shasum";
constexpr const char* WRITING_CODERESOURCES_FAILED = "writing_coderesources_failed";
constexpr const char* CANT_WRITE_PROVISION = "cant_write_provision";
constexpr const char* CANT_FIND_PLUGIN_INFO = "cant_find_plugin_info";
constexpr const char* BUNDLE_ID = "bundle_id";
constexpr const char* BUNDLE_ID_VALUE = "bundle_id_value";
constexpr const char* BUNDLE_ID_PLUGIN = "bundle_id_plugin";
constexpr const char* BUNDLE_ID_WK = "bundle_id_wk";
constexpr const char* BUNDLE_ID_EXT = "bundle_id_ext";
constexpr const char* CANT_FIND_APP_INFO = "cant_find_app_info";
constexpr const char* BUNDLE_NAME = "bundle_name";
constexpr const char* BUNDLE_VERSION = "bundle_version";
constexpr const char* ENABLED_DOCUMENTS = "enabled_documents";
constexpr const char* MIN_OS_VERSION = "min_os_version";
constexpr const char* REMOVED = "removed";
constexpr const char* REMOVED_UI_DEVICES = "removed_ui_devices";
constexpr const char* CANT_FIND_APP_FOLDER = "cant_find_app_folder";
constexpr const char* CANT_GET_INFO_PLIST = "cant_get_info_plist";
constexpr const char* SIGN_FOLDER = "sign_folder";
constexpr const char* SIGNING_APP = "signing_app";
constexpr const char* APP_NAME = "app_name";
constexpr const char* VERSION = "version";
constexpr const char* TEAM_ID = "team_id";
constexpr const char* SUBJECT_CN = "subject_cn";
constexpr const char* READ_CACHE = "read_cache";
constexpr const char* CACHE_YES = "cache_yes";
constexpr const char* CACHE_NO = "cache_no";

// 通用
constexpr const char* ADHOC = "adhoc";

} // namespace ZL10nKeys

#endif /* log_keys_h */
