#include "cash_changer_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <sstream>
#include "opos_all.h"

namespace cash_changer {
// static
void CashChangerPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "cash_changer",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<CashChangerPlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

CashChangerPlugin::CashChangerPlugin() {

    std::cerr << "CashChangerPlugin construct" << std::endl;
    // 创建 COM 对象实例
    HRESULT hr = pCashChanger.CreateInstance(__uuidof(OPOSCashChanger));
    if (FAILED(hr)) {
        std::cerr << "创建 COM 实例失败" << std::endl;
        //result->Error("COM_ERROR", "创建 COM 实例失败");
        //return;
    }
}

CashChangerPlugin::~CashChangerPlugin() {
    std::cerr << "CashChangerPlugin destruct" << std::endl;
    // 释放 COM 对象
    if (pCashChanger) {
        pCashChanger->Release();
        pCashChanger = NULL;
    }
}

void CashChangerPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {

 if (method_call.method_name().compare("openCashChanger") == 0) {
    std::cerr << "openCashChange called 。。" << std::endl;
        // 创建 OPOSCashChanger 接口指针
        //IOPOSCashChangerPtr pCashChanger;
        // 打开现金机
        long lngRet = pCashChanger->Open("CashChanger");
        // 检查是否已经打开
        if (lngRet == OposEIllegal) {
            lngRet = OposSuccess;
        }
        if (lngRet == OposSuccess) {
          if (pCashChanger->Claimed == VARIANT_FALSE) {
            // 获取排他访问权限
            lngRet = pCashChanger->ClaimDevice(10000);
          if (lngRet == 0) {
                // 设置设备属性
                pCashChanger->DeviceEnabled = VARIANT_TRUE;
                pCashChanger->DataEventEnabled = VARIANT_TRUE;
                pCashChanger->FreezeEvents = VARIANT_FALSE;

                // 执行 DirectIO (根据您的需要可能需要修改参数)
                long data = 0;
                BSTR bstr = SysAllocString(L"");
                lngRet = pCashChanger->DirectIO(18, &data, &bstr);
                SysFreeString(bstr);
                result->Success(flutter::EncodableValue(true));
            } else {
                cerr << "ClaimDevice 失败，错误码：" << lngRet << endl;
            }
        } else {
            // 设备已被声明，设置属性
            pCashChanger->DeviceEnabled = VARIANT_TRUE;
            pCashChanger->DataEventEnabled = VARIANT_TRUE;
            pCashChanger->FreezeEvents = VARIANT_FALSE;
        }
        } else {
            cerr << "打开设备失败，错误码：" << lngRet << endl;
            result->Error("OPEN_FAILURE", "打开设备失败");
        }
    return;
  }

  if (method_call.method_name().compare("closeCashChanger") == 0) {
    std::cerr << "closeCashChanger called 。。" << std::endl;

        if (pCashChanger == NULL) {
        // 如果 pCashChanger 为空，直接返回
        return;
    }

    // 禁用设备
    pCashChanger->DeviceEnabled = VARIANT_FALSE;

    // 释放设备
    long lngRet = pCashChanger->ReleaseDevice();
    // 可以记录或处理 lngRet 来了解 ReleaseDevice 的执行情况

    // 关闭设备，释放资源
    lngRet = pCashChanger->Close();

    if (lngRet == 0) {
        // 释放 COM 对象
        // pCashChanger->Release();
        // pCashChanger = NULL;
        result->Success(flutter::EncodableValue(true));
    } else {
        cerr << "关闭设备失败，错误码：" << lngRet << endl;
        result->Error("CLOSE_FAILURE", "关闭设备失败");
    }

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

}  // namespace cash_changer
