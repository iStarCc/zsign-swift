//
//  zsign.mm
//  zsign-swift
//
//  Objective-C++ bridge for Swift iOS/macOS - based on zsign new code
//

#include "zsign.hpp"
#include "common.h"
#include "openssl.h"
#include "macho.h"
#include "bundle.h"
#include "timer.h"
#include "log.h"
#include "log_keys.h"
#include "common/archive.h"

#include <openssl/ocsp.h>

static void(^s_logHandler)(NSString*) = nil;

static void ZLogBridge(const char* szLog, int nColor) {
	if (s_logHandler && szLog) {
		NSString* ns = [NSString stringWithUTF8String:szLog];
		s_logHandler(ns);
	}
}

struct ZLogGuard {
	bool active;
	ZLogGuard(void(^h)(NSString*)) : active(h != nil) {
		if (active) {
			s_logHandler = h;
			ZLog::SetLogCallback(ZLogBridge);
		}
	}
	~ZLogGuard() {
		if (active) {
			ZLog::ClearLogCallback();
			s_logHandler = nil;
		}
	}
};
#include <openssl/x509.h>
#include <openssl/pem.h>
#include <openssl/bio.h>
#include <openssl/ssl.h>
#include <openssl/err.h>
#include <openssl/asn1.h>

extern "C" {

void ZsignSetLogLocale(const char* locale) {
	ZL10n::SetLocale(locale);
}

bool CheckIfSigned(NSString *filePath) {
	ZTimer gtimer;
	@autoreleasepool {
		std::string filePathStr = [filePath UTF8String];
		
		ZMachO machO;
		bool initSuccess = machO.Init(filePathStr.c_str());
		if (!initSuccess) {
			gtimer.Print(">>> Failed to initialize ZMachO.");
			return false;
		}
		
		bool success = machO.CheckSignature();
		
		machO.Free();
		
		if (success) {
			gtimer.Print(">>> MachO is signed!");
			return true;
		} else {
			gtimer.Print(">>> MachO is not signed.");
			return false;
		}
	}
}

bool InjectDyLib(NSString *filePath, NSString *dylibPath, bool weakInject) {
	ZTimer gtimer;
	@autoreleasepool {
		std::string filePathStr = [filePath UTF8String];
		std::string dylibPathStr = [dylibPath UTF8String];
		
		ZMachO machO;
		bool initSuccess = machO.Init(filePathStr.c_str());
		if (!initSuccess) {
			gtimer.Print(">>> Failed to initialize ZMachO.");
			return false;
		}
		
		bool success = machO.InjectDylib(weakInject, dylibPathStr.c_str());
		
		machO.Free();
		
		if (success) {
			gtimer.Print(">>> Dylib injected successfully!");
			return true;
		} else {
			gtimer.Print(">>> Failed to inject dylib.");
			return false;
		}
	}
}

bool UninstallDylibs(NSString *filePath, NSArray<NSString *> *dylibPathsArray) {
	ZTimer gtimer;
	@autoreleasepool {
		std::string filePathStr = [filePath UTF8String];
		std::set<std::string> dylibsToRemove;
		
		for (NSString *dylibPath in dylibPathsArray) {
			dylibsToRemove.insert([dylibPath UTF8String]);
		}
		
		ZMachO machO;
		bool initSuccess = machO.Init(filePathStr.c_str());
		if (!initSuccess) {
			gtimer.Print(">>> Failed to initialize ZMachO.");
			return false;
		}
		
		machO.RemoveDylibs(dylibsToRemove);
		
		machO.Free();
		
		gtimer.Print(">>> Dylibs uninstalled successfully!");
		return true;
	}
}

NSArray<NSString *> *ListDylibs(NSString *filePath) {
	ZTimer gtimer;
	@autoreleasepool {
		NSMutableArray<NSString *> *dylibPathsArray = [NSMutableArray array];
		
		std::string filePathStr = [filePath UTF8String];
		
		ZMachO machO;
		bool initSuccess = machO.Init(filePathStr.c_str());
		if (!initSuccess) {
			gtimer.Print(">>> Failed to initialize ZMachO.");
			return nil;
		}
		
		std::vector<std::string> dylibPaths = machO.ListDylibs();
		
		if (!dylibPaths.empty()) {
			gtimer.Print(">>> List of dylibs in the Mach-O file:");
			for (const std::string &dylibPath : dylibPaths) {
				NSString *dylibPathStr = [NSString stringWithUTF8String:dylibPath.c_str()];
				[dylibPathsArray addObject:dylibPathStr];
			}
		} else {
			gtimer.Print(">>> No dylibs found in the Mach-O file.");
		}
		
		machO.Free();
		
		return [dylibPathsArray copy];
	}
}

bool ChangeDylibPath(NSString *filePath, NSString *oldPath, NSString *newPath) {
	ZTimer gtimer;
	@autoreleasepool {
		std::string filePathStr = [filePath UTF8String];
		std::string oldPathStr = [oldPath UTF8String];
		std::string newPathStr = [newPath UTF8String];
		
		ZMachO machO;
		bool initSuccess = machO.Init(filePathStr.c_str());
		if (!initSuccess) {
			gtimer.Print(">>> Failed to initialize ZMachO.");
			return false;
		}
		
		bool success = machO.ChangeDylibPath(oldPathStr.c_str(), newPathStr.c_str());
		
		machO.Free();
		
		if (success) {
			gtimer.Print(">>> Dylib path changed successfully!");
			return true;
		} else {
			gtimer.Print(">>> Failed to change dylib path.");
			return false;
		}
	}
}

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
	bool excludeprovion,
	void(^completionHandler)(BOOL success, NSError *error),
	void(^logHandler)(NSString *log)
) {
	ZLogGuard logGuard(logHandler);
	ZTimer atimer;
	ZTimer gtimer;
	
	bool bForce = true;
	bool bWeakInject = false;
	bool bAdhoc = adhoc;
	bool bSHA256Only = false;
	
	string strCertFile;
	string strPKeyFile;
	string strProvFile;
	string strPassword;
	string strBundleId;
	string strBundleVersion;
	string strDisplayName;
	string strEntitleFile;
	vector<string> arrDylibFiles;
	vector<string> arrRemoveDylibNames;
	
	strPKeyFile = [key cStringUsingEncoding:NSUTF8StringEncoding];
	strProvFile = [prov cStringUsingEncoding:NSUTF8StringEncoding];
	strPassword = [pass cStringUsingEncoding:NSUTF8StringEncoding];
	strEntitleFile = [entitlement cStringUsingEncoding:NSUTF8StringEncoding];
	
	strBundleId = [bundleid cStringUsingEncoding:NSUTF8StringEncoding];
	strDisplayName = [displayname cStringUsingEncoding:NSUTF8StringEncoding];
	strBundleVersion = [bundleversion cStringUsingEncoding:NSUTF8StringEncoding];
	
	string strPath = [app cStringUsingEncoding:NSUTF8StringEncoding];
	if (!ZFile::IsFileExists(strPath.c_str())) {
		ZLog::ErrorV(ZL10n::GetFmt(ZL10nKeys::INVALID_PATH), strPath.c_str());
		return -1;
	}
	
	ZSignAsset zsa;
	if (!zsa.Init(strCertFile, strPKeyFile, strProvFile, strEntitleFile, strPassword, bAdhoc, bSHA256Only, false)) {
		return -1;
	}
	
	bool bEnableCache = true;
	string strFolder = strPath;
	
	atimer.Reset();
	ZBundle bundle;
	bool bRet = bundle.SignFolder(&zsa, strFolder, strBundleId, strBundleVersion, strDisplayName, arrDylibFiles, arrRemoveDylibNames, bForce, bWeakInject, bEnableCache, excludeprovion);
	ZLog::PrintV(ZL10n::GetFmt(ZL10nKeys::SIGNING), ZUtil::GetBaseName(strPath.c_str()), (bAdhoc ? ZL10n::Get(ZL10nKeys::ADHOC) : ""));
	atimer.PrintResult(bRet, ZL10n::GetFmt(ZL10nKeys::SIGNED_FMT), bRet ? ZL10n::Get(ZL10nKeys::SIGNED_OK) : ZL10n::Get(ZL10nKeys::SIGNED_FAILED));
	
	NSError* signError = nil;
	if(!bundle.signFailedFiles.empty()) {
		NSDictionary* userInfo = @{
			NSLocalizedDescriptionKey : [NSString stringWithUTF8String:bundle.signFailedFiles.c_str()]
		};
		signError = [NSError errorWithDomain:@"Failed to Sign" code:-1 userInfo:userInfo];
	}
	
	completionHandler(bRet, signError);
	
	gtimer.Print(ZL10n::Get(ZL10nKeys::DONE));
	return bRet ? 0 : -1;
}

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
) {
	ZLogGuard logGuard(logHandler);
	ZTimer atimer;
	ZTimer gtimer;
	
	bool bForce = true;
	bool bWeakInject = false;
	bool bAdhoc = adhoc;
	bool bSHA256Only = false;
	int nZipLevel = (zipLevel >= 0 && zipLevel <= 9) ? zipLevel : 6;
	
	string strCertFile;
	string strPKeyFile = [key cStringUsingEncoding:NSUTF8StringEncoding];
	string strProvFile = [prov cStringUsingEncoding:NSUTF8StringEncoding];
	string strPassword = [pass cStringUsingEncoding:NSUTF8StringEncoding];
	string strEntitleFile = [entitlement cStringUsingEncoding:NSUTF8StringEncoding];
	string strBundleId = [bundleid cStringUsingEncoding:NSUTF8StringEncoding];
	string strBundleVersion = [bundleversion cStringUsingEncoding:NSUTF8StringEncoding];
	string strDisplayName = [displayname cStringUsingEncoding:NSUTF8StringEncoding];
	vector<string> arrDylibFiles;
	vector<string> arrRemoveDylibNames;
	
	string strPath = [inputPath cStringUsingEncoding:NSUTF8StringEncoding];
	string strOutputFile = [outputPath cStringUsingEncoding:NSUTF8StringEncoding];
	
	if (!ZFile::IsFileExists(strPath.c_str())) {
		ZLog::ErrorV(ZL10n::GetFmt(ZL10nKeys::INVALID_INPUT_PATH), strPath.c_str());
		if (completionHandler) completionHandler(NO, [NSError errorWithDomain:@"Zsign" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Invalid input path"}]);
		return -1;
	}
	if (strOutputFile.empty()) {
		ZLog::ErrorV(ZL10n::GetFmt(ZL10nKeys::OUTPUT_PATH_REQUIRED));
		if (completionHandler) completionHandler(NO, [NSError errorWithDomain:@"Zsign" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Output path is required"}]);
		return -1;
	}
	
	ZSignAsset zsa;
	if (!zsa.Init(strCertFile, strPKeyFile, strProvFile, strEntitleFile, strPassword, bAdhoc, bSHA256Only, false)) {
		if (completionHandler) completionHandler(NO, [NSError errorWithDomain:@"Zsign" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Failed to init certificate"}]);
		return -1;
	}
	
	bool bZipFile = ZFile::IsZipFile(strPath.c_str());
	bool bTempFolder = false;
	bool bEnableCache = true;
	string strFolder = strPath;
	string strTempFolder = ZFile::GetTempFolder();
	
	if (bZipFile) {
		bForce = true;
		bTempFolder = true;
		bEnableCache = false;
		strFolder = ZFile::GetRealPathV("%s/zsign_folder_%llu", strTempFolder.c_str(), ZUtil::GetMicroSecond());
		ZLog::PrintV(ZL10n::GetFmt(ZL10nKeys::UNZIP), ZUtil::GetBaseName(strPath.c_str()), ZFile::GetFileSizeString(strPath.c_str()).c_str());
		if (!Zip::Extract(strPath.c_str(), strFolder.c_str())) {
			ZLog::ErrorV(ZL10n::GetFmt(ZL10nKeys::UNZIP_FAILED));
			if (completionHandler) completionHandler(NO, [NSError errorWithDomain:@"Zsign" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Unzip failed"}]);
			return -1;
		}
		atimer.PrintResult(true, ZL10n::Get(ZL10nKeys::UNZIP_OK));
	}
	
	atimer.Reset();
	ZBundle bundle;
	bool bRet = bundle.SignFolder(&zsa, strFolder, strBundleId, strBundleVersion, strDisplayName, arrDylibFiles, arrRemoveDylibNames, bForce, bWeakInject, bEnableCache, excludeprovion);
	ZLog::PrintV(ZL10n::GetFmt(ZL10nKeys::SIGNING), ZUtil::GetBaseName(strPath.c_str()), (bAdhoc ? ZL10n::Get(ZL10nKeys::ADHOC) : ""));
	atimer.PrintResult(bRet, ZL10n::GetFmt(ZL10nKeys::SIGNED_FMT), bRet ? ZL10n::Get(ZL10nKeys::SIGNED_OK) : ZL10n::Get(ZL10nKeys::SIGNED_FAILED));
	
	if (bRet && !strOutputFile.empty()) {
		atimer.Reset();
		ZLog::PrintV(ZL10n::GetFmt(ZL10nKeys::ARCHIVING), ZUtil::GetBaseName(strOutputFile.c_str()));
		string strBaseFolder;
		bool bNeedCleanPayload = false;
		size_t pos = bundle.m_strAppFolder.rfind("Payload");
		if (pos != string::npos && pos > 0) {
			strBaseFolder = bundle.m_strAppFolder.substr(0, pos - 1);
		} else {
			// 输入为 .app 目录，创建临时 Payload 结构（使用 NSFileManager 递归复制，兼容 iOS）
			string strPayloadRoot = ZFile::GetRealPathV("%s/zsign_payload_%llu", strTempFolder.c_str(), ZUtil::GetMicroSecond());
			string strPayloadFolder = strPayloadRoot + "/Payload";
			string strAppName = ZUtil::GetBaseName(bundle.m_strAppFolder.c_str());
			NSString* srcApp = [NSString stringWithUTF8String:bundle.m_strAppFolder.c_str()];
			NSString* destApp = [NSString stringWithUTF8String:(strPayloadFolder + "/" + strAppName).c_str()];
			NSFileManager* fm = [NSFileManager defaultManager];
			if (![fm createDirectoryAtPath:[NSString stringWithUTF8String:strPayloadFolder.c_str()] withIntermediateDirectories:YES attributes:nil error:nil]) {
				ZLog::Error(ZL10n::GetFmt(ZL10nKeys::FAILED_CREATE_PAYLOAD));
				bRet = false;
			} else {
				NSError* copyErr = nil;
				if (![fm copyItemAtPath:srcApp toPath:destApp error:&copyErr]) {
					ZLog::ErrorV(ZL10n::GetFmt(ZL10nKeys::FAILED_COPY_APP), copyErr ? [[copyErr localizedDescription] UTF8String] : "unknown");
					bRet = false;
					ZFile::RemoveFolder(strPayloadRoot.c_str());
				} else {
					strBaseFolder = strPayloadRoot;
					bNeedCleanPayload = true;
				}
			}
		}
		if (bRet && !strBaseFolder.empty()) {
			if (!Zip::Archive(strBaseFolder.c_str(), strOutputFile.c_str(), nZipLevel)) {
				ZLog::Error(ZL10n::GetFmt(ZL10nKeys::ARCHIVE_FAILED));
				bRet = false;
			} else {
				atimer.PrintResult(true, ZL10n::GetFmt(ZL10nKeys::ARCHIVE_OK), ZFile::GetFileSizeString(strOutputFile.c_str()).c_str());
			}
			if (bNeedCleanPayload) {
				ZFile::RemoveFolder(strBaseFolder.c_str());
			}
		}
	}
	
	if (bTempFolder) {
		ZFile::RemoveFolder(strFolder.c_str());
	}
	
	NSError *signError = nil;
	if (!bRet && !bundle.signFailedFiles.empty()) {
		signError = [NSError errorWithDomain:@"Zsign" code:-1 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithUTF8String:bundle.signFailedFiles.c_str()]}];
	}
	if (completionHandler) completionHandler(bRet, signError);
	
	gtimer.Print(ZL10n::Get(ZL10nKeys::DONE));
	return bRet ? 0 : -1;
}

int checkCert(
	NSString *prov,
	NSString *key,
	NSString *pass,
	void(^completionHandler)(int status, NSDate* expirationDate, NSString *error)
) {
	ZTimer gtimer;
	
	string strCertFile;
	string strPKeyFile;
	string strProvFile;
	string strPassword;
	string strEntitleFile;
		
	if (!key || !prov || !pass) {
		completionHandler(2, nil, @"One or more required paths or password is missing.");
		return -1;
	}
		
	strPKeyFile = [key cStringUsingEncoding:NSUTF8StringEncoding];
	strProvFile = [prov cStringUsingEncoding:NSUTF8StringEncoding];
	strPassword = [pass cStringUsingEncoding:NSUTF8StringEncoding];

	__block ZSignAsset zsa;
		
	if (!zsa.Init(strCertFile, strPKeyFile, strProvFile, strEntitleFile, strPassword, false, false, false)) {
		completionHandler(2, nil, @"Unable to initialize certificate. Please check your password.");
		return -1;
	}
		
	X509* cert = (X509*)zsa.m_x509Cert;
	BIO *brother1;
	unsigned long issuerHash = X509_issuer_name_hash((X509*)cert);
	if (0x817d2f7a == issuerHash) {
		brother1 = BIO_new_mem_buf(ZSignAsset::s_szAppleDevCACert, (int)strlen(ZSignAsset::s_szAppleDevCACert));
	} else if (0x9b16b75c == issuerHash) {
		brother1 = BIO_new_mem_buf(ZSignAsset::s_szAppleDevCACertG3, (int)strlen(ZSignAsset::s_szAppleDevCACertG3));
	} else {
		completionHandler(2, nil, @"Unable to determine issuer of the certificate. It is signed by Apple Developer?");
		return -2;
	}
		
	if (!brother1)
	{
		completionHandler(2, nil, @"Unable to initialize issuer certificate.");
		return -3;
	}
		
	X509 *issuer = PEM_read_bio_X509(brother1, NULL, 0, NULL);
	
	if (!cert || !issuer) {
		completionHandler(2, nil, @"Error loading cert or issuer");
		return -4;
	}
	
	// Extract OCSP URL from cert
	STACK_OF(ACCESS_DESCRIPTION)* aia = (STACK_OF(ACCESS_DESCRIPTION)*)X509_get_ext_d2i((X509*)cert, NID_info_access, 0, 0);
	if (!aia) {
		completionHandler(2, nil, @"No AIA (OCSP) extension found in certificate");
		return -5;
	}
	
	ASN1_IA5STRING* uri = nullptr;
	for (int i = 0; i < sk_ACCESS_DESCRIPTION_num(aia); i++) {
		ACCESS_DESCRIPTION* ad = sk_ACCESS_DESCRIPTION_value(aia, i);
		if (OBJ_obj2nid(ad->method) == NID_ad_OCSP &&
			ad->location->type == GEN_URI) {
			uri = ad->location->d.uniformResourceIdentifier;
			
			break;
		}
	}
	
	if (!uri) {
		completionHandler(2, nil, @"No OCSP URI found in certificate.");
		return -6;
	}
	
	OCSP_REQUEST* req = OCSP_REQUEST_new();
	OCSP_CERTID* cert_id = OCSP_cert_to_id(nullptr, (X509*)cert, issuer);
	OCSP_request_add0_id(req, cert_id);  // Ownership transferred to request
	cert_id = OCSP_cert_to_id(nullptr, (X509*)cert, issuer);
	unsigned char* der = 0;
	int len = i2d_OCSP_REQUEST(req, &der);
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithUTF8String:(const char *)uri->data]]];
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:[NSData dataWithBytes:der length:len]];
	[request setValue:@"application/ocsp-request" forHTTPHeaderField:@"Content-Type"];
	[request setValue:@"application/ocsp-response" forHTTPHeaderField:@"Accept"];
	
	OPENSSL_free(der);
	if (aia) {
		sk_ACCESS_DESCRIPTION_pop_free(aia, ACCESS_DESCRIPTION_free);
	}
	OCSP_REQUEST_free(req);
	X509_free(issuer);
	BIO_free(brother1);
	
	NSURLSession *session = [NSURLSession sharedSession];
	NSURLSessionDataTask *task = [session dataTaskWithRequest:request
											completionHandler:^(NSData * _Nullable data,
																NSURLResponse * _Nullable response,
																NSError * _Nullable error) {
		if (error) {
			completionHandler(2, nil, error.localizedDescription);
			return;
		}
		
		NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
		if (httpResponse.statusCode == 200 && data) {
			const void *respBytes = [data bytes];
			OCSP_RESPONSE *resp;
			d2i_OCSP_RESPONSE(&resp, (const unsigned char**)&respBytes, data.length);
			OCSP_BASICRESP *basic = OCSP_response_get1_basic(resp);
			ASN1_TIME *expirationDateAsn1 = X509_get_notAfter(cert);
			NSString *fullDateString = [NSString stringWithFormat:@"20%s", expirationDateAsn1->data];
			
			NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
			formatter.dateFormat = @"yyyyMMddHHmmss'Z'";
			formatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
			formatter.locale = NSLocale.currentLocale;
			NSDate *expirationDate = [formatter dateFromString:fullDateString];
			
			int status, reason;
			if (OCSP_resp_find_status(basic, cert_id, &status, &reason, NULL, NULL, NULL)) {
				completionHandler(status, expirationDate, nil);
			} else {
				completionHandler(2, expirationDate, nil);
			}
			
			OCSP_CERTID_free(cert_id);
			OCSP_BASICRESP_free(basic);
			OCSP_RESPONSE_free(resp);
			
		} else {
			completionHandler(2, nil, @"Invalid response or no data");
			return;
		}
	}];
	
	[task resume];
	return 1;
}

}
