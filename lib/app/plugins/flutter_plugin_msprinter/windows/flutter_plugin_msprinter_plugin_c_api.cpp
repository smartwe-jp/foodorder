#include "include/flutter_plugin_msprinter/flutter_plugin_msprinter_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "flutter_plugin_msprinter_plugin.h"

void FlutterPluginMsprinterPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  flutter_plugin_msprinter::FlutterPluginMsprinterPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
