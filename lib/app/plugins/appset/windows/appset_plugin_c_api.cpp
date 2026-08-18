#include "include/appset/appset_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "appset_plugin.h"

void AppsetPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  appset::AppsetPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
