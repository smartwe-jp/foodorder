#include "appset_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <sstream>

namespace appset {

// static
void AppsetPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "appset",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<AppsetPlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

AppsetPlugin::AppsetPlugin() {}

AppsetPlugin::~AppsetPlugin() {}

void AppsetPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {

  
  if (method_call.method_name().compare("showBullyScreen") == 0) {

    HWND hwnd = GetActiveWindow(); // 获取当前活动窗口的句柄
    DWORD style = GetWindowLong(hwnd, GWL_STYLE); // 获取窗口的样式

    // 恢复窗口的样式
    SetWindowLong(hwnd, GWL_STYLE, style | WS_OVERLAPPEDWINDOW);

    // 获取窗口的原始大小
    RECT rect;
    GetWindowRect(hwnd, &rect);

    // 恢复窗口的大小
    SetWindowPos(hwnd, NULL, rect.left, rect.top, rect.right - rect.left, rect.bottom - rect.top, SWP_FRAMECHANGED | SWP_NOZORDER | SWP_NOOWNERZORDER);
    result->Success(flutter::EncodableValue("success"));
    return;
  }

  if (method_call.method_name().compare("hideBullyScreen") == 0) {
    cerr << "hideBullyScreen" << endl;
    HWND hwnd = GetActiveWindow(); // 获取当前活动窗口的句柄
    DWORD style = GetWindowLong(hwnd, GWL_STYLE); // 获取窗口的样式
    // 设置窗口的样式为全屏
    SetWindowLong(hwnd, GWL_STYLE, style & ~WS_OVERLAPPEDWINDOW);
    // 获取屏幕的大小
    RECT rect;
    GetWindowRect(GetDesktopWindow(), &rect);
    // 设置窗口的大小为全屏
    SetWindowPos(hwnd, HWND_TOP, 0, 0, rect.right, rect.bottom, SWP_FRAMECHANGED);
    cerr << "hideBullyScreen end" << endl;
    result->Success(flutter::EncodableValue("success"));
    return;
  }

  if (method_call.method_name().compare("getPlatformVersion") == 0) {
    std::ostringstream version_stream;
    version_stream << "Windows ";
    if (IsWindows10OrGreater()) {
      version_stream << "10+";
    } else if (IsWindows8OrGreater()) {
      version_stream << "8";
    } else if (IsWindows7OrGreater()) {
      version_stream << "7";
    }
    result->Success(flutter::EncodableValue(version_stream.str()));
  } else {
    result->NotImplemented();
  }
}

}  // namespace appset
