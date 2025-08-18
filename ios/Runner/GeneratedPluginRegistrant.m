//
//  Generated file. Do not edit.
//

// clang-format off

#import "GeneratedPluginRegistrant.h"

#if __has_include(<appset/AppsetPlugin.h>)
#import <appset/AppsetPlugin.h>
#else
@import appset;
#endif

#if __has_include(<assets_audio_player/AssetsAudioPlayerPlugin.h>)
#import <assets_audio_player/AssetsAudioPlayerPlugin.h>
#else
@import assets_audio_player;
#endif

#if __has_include(<charset_converter/CharsetConverterPlugin.h>)
#import <charset_converter/CharsetConverterPlugin.h>
#else
@import charset_converter;
#endif

#if __has_include(<connectivity_plus/ConnectivityPlusPlugin.h>)
#import <connectivity_plus/ConnectivityPlusPlugin.h>
#else
@import connectivity_plus;
#endif

#if __has_include(<firebase_analytics/FirebaseAnalyticsPlugin.h>)
#import <firebase_analytics/FirebaseAnalyticsPlugin.h>
#else
@import firebase_analytics;
#endif

#if __has_include(<firebase_core/FLTFirebaseCorePlugin.h>)
#import <firebase_core/FLTFirebaseCorePlugin.h>
#else
@import firebase_core;
#endif

#if __has_include(<firebase_crashlytics/FLTFirebaseCrashlyticsPlugin.h>)
#import <firebase_crashlytics/FLTFirebaseCrashlyticsPlugin.h>
#else
@import firebase_crashlytics;
#endif

#if __has_include(<flutter_plugin_msprinter/FlutterPluginMsprinterPlugin.h>)
#import <flutter_plugin_msprinter/FlutterPluginMsprinterPlugin.h>
#else
@import flutter_plugin_msprinter;
#endif

#if __has_include(<fluttertoast/FluttertoastPlugin.h>)
#import <fluttertoast/FluttertoastPlugin.h>
#else
@import fluttertoast;
#endif

#if __has_include(<open_file_ios/OpenFilePlugin.h>)
#import <open_file_ios/OpenFilePlugin.h>
#else
@import open_file_ios;
#endif

#if __has_include(<package_info_plus/FPPPackageInfoPlusPlugin.h>)
#import <package_info_plus/FPPPackageInfoPlusPlugin.h>
#else
@import package_info_plus;
#endif

#if __has_include(<path_provider_foundation/PathProviderPlugin.h>)
#import <path_provider_foundation/PathProviderPlugin.h>
#else
@import path_provider_foundation;
#endif

#if __has_include(<paycube_old/PaycubePlugin.h>)
#import <paycube_old/PaycubePlugin.h>
#else
@import paycube_old;
#endif

#if __has_include(<permission_handler_apple/PermissionHandlerPlugin.h>)
#import <permission_handler_apple/PermissionHandlerPlugin.h>
#else
@import permission_handler_apple;
#endif

#if __has_include(<r_get_ip/RGetIpPlugin.h>)
#import <r_get_ip/RGetIpPlugin.h>
#else
@import r_get_ip;
#endif

#if __has_include(<shared_preferences_foundation/SharedPreferencesPlugin.h>)
#import <shared_preferences_foundation/SharedPreferencesPlugin.h>
#else
@import shared_preferences_foundation;
#endif

#if __has_include(<sqflite_darwin/SqflitePlugin.h>)
#import <sqflite_darwin/SqflitePlugin.h>
#else
@import sqflite_darwin;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [AppsetPlugin registerWithRegistrar:[registry registrarForPlugin:@"AppsetPlugin"]];
  [AssetsAudioPlayerPlugin registerWithRegistrar:[registry registrarForPlugin:@"AssetsAudioPlayerPlugin"]];
  [CharsetConverterPlugin registerWithRegistrar:[registry registrarForPlugin:@"CharsetConverterPlugin"]];
  [ConnectivityPlusPlugin registerWithRegistrar:[registry registrarForPlugin:@"ConnectivityPlusPlugin"]];
  [FirebaseAnalyticsPlugin registerWithRegistrar:[registry registrarForPlugin:@"FirebaseAnalyticsPlugin"]];
  [FLTFirebaseCorePlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTFirebaseCorePlugin"]];
  [FLTFirebaseCrashlyticsPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTFirebaseCrashlyticsPlugin"]];
  [FlutterPluginMsprinterPlugin registerWithRegistrar:[registry registrarForPlugin:@"FlutterPluginMsprinterPlugin"]];
  [FluttertoastPlugin registerWithRegistrar:[registry registrarForPlugin:@"FluttertoastPlugin"]];
  [OpenFilePlugin registerWithRegistrar:[registry registrarForPlugin:@"OpenFilePlugin"]];
  [FPPPackageInfoPlusPlugin registerWithRegistrar:[registry registrarForPlugin:@"FPPPackageInfoPlusPlugin"]];
  [PathProviderPlugin registerWithRegistrar:[registry registrarForPlugin:@"PathProviderPlugin"]];
  [PaycubePlugin registerWithRegistrar:[registry registrarForPlugin:@"PaycubePlugin"]];
  [PermissionHandlerPlugin registerWithRegistrar:[registry registrarForPlugin:@"PermissionHandlerPlugin"]];
  [RGetIpPlugin registerWithRegistrar:[registry registrarForPlugin:@"RGetIpPlugin"]];
  [SharedPreferencesPlugin registerWithRegistrar:[registry registrarForPlugin:@"SharedPreferencesPlugin"]];
  [SqflitePlugin registerWithRegistrar:[registry registrarForPlugin:@"SqflitePlugin"]];
}

@end
