#ifndef FLUTTER_PLUGIN_CASH_CHANGER_PLUGIN_H_
#define FLUTTER_PLUGIN_CASH_CHANGER_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>
#include "64OPOSCashChanger.tlh"

using namespace OposCashChanger_CCO;
using namespace std;

namespace cash_changer {

class CashChangerPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  CashChangerPlugin();

  virtual ~CashChangerPlugin();

  // Disallow copy and assign.
  CashChangerPlugin(const CashChangerPlugin&) = delete;
  CashChangerPlugin& operator=(const CashChangerPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

    private:
        
      IOPOSCashChangerPtr pCashChanger;

        
};

}  // namespace cash_changer

#endif  // FLUTTER_PLUGIN_CASH_CHANGER_PLUGIN_H_
