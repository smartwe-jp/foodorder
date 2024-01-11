#ifndef FLUTTER_PLUGIN_APPSET_PLUGIN_H_
#define FLUTTER_PLUGIN_APPSET_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

using namespace std;

namespace appset {

class AppsetPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  AppsetPlugin();

  virtual ~AppsetPlugin();

  // Disallow copy and assign.
  AppsetPlugin(const AppsetPlugin&) = delete;
  AppsetPlugin& operator=(const AppsetPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace appset

#endif  // FLUTTER_PLUGIN_APPSET_PLUGIN_H_
