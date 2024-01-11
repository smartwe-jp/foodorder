#ifndef FLUTTER_PLUGIN_FLUTTER_PLUGIN_MSPRINTER_PLUGIN_H_
#define FLUTTER_PLUGIN_FLUTTER_PLUGIN_MSPRINTER_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace flutter_plugin_msprinter {

class FlutterPluginMsprinterPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  FlutterPluginMsprinterPlugin();

  virtual ~FlutterPluginMsprinterPlugin();

  // Disallow copy and assign.
  FlutterPluginMsprinterPlugin(const FlutterPluginMsprinterPlugin&) = delete;
  FlutterPluginMsprinterPlugin& operator=(const FlutterPluginMsprinterPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace flutter_plugin_msprinter

#endif  // FLUTTER_PLUGIN_FLUTTER_PLUGIN_MSPRINTER_PLUGIN_H_
