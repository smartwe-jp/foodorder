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
#include <dynamic_color/dynamic_color_plugin_c_api.h>
#include <flutter_libserialport/flutter_libserialport_plugin.h>
#include <flutter_plugin_msprinter/flutter_plugin_msprinter_plugin_c_api.h>
#include <permission_handler_windows/permission_handler_windows_plugin.h>
#include <r_get_ip/r_get_ip_plugin.h>

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
  DynamicColorPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("DynamicColorPluginCApi"));
  FlutterLibserialportPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterLibserialportPlugin"));
  FlutterPluginMsprinterPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterPluginMsprinterPluginCApi"));
  PermissionHandlerWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("PermissionHandlerWindowsPlugin"));
  RGetIpPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("RGetIpPlugin"));
}
