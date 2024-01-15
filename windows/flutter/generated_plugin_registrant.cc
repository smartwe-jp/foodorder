//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <appset/appset_plugin_c_api.h>
#include <audioplayers_windows/audioplayers_windows_plugin.h>
#include <cash_changer/cash_changer_plugin_c_api.h>
#include <charset_converter/charset_converter_plugin.h>
#include <connectivity_plus/connectivity_plus_windows_plugin.h>
#include <firebase_core/firebase_core_plugin_c_api.h>
#include <flutter_plugin_msprinter/flutter_plugin_msprinter_plugin_c_api.h>
#include <permission_handler_windows/permission_handler_windows_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  AppsetPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("AppsetPluginCApi"));
  AudioplayersWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("AudioplayersWindowsPlugin"));
  CashChangerPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("CashChangerPluginCApi"));
  CharsetConverterPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("CharsetConverterPlugin"));
  ConnectivityPlusWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("ConnectivityPlusWindowsPlugin"));
  FirebaseCorePluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FirebaseCorePluginCApi"));
  FlutterPluginMsprinterPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterPluginMsprinterPluginCApi"));
  PermissionHandlerWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("PermissionHandlerWindowsPlugin"));
}
