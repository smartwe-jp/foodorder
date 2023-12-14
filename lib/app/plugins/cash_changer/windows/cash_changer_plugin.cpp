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
                result->Success(flutter::EncodableValue(lngRet));
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
            //result->Error("OPEN_FAILURE", "打开设备失败");
            result->Success(flutter::EncodableValue(lngRet));
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

    if (lngRet == OposSuccess) {
        // 释放 COM 对象
        // pCashChanger->Release();
        // pCashChanger = NULL;
        result->Success(flutter::EncodableValue(true));
    } else {
        cerr << "关闭设备失败，错误码：" << lngRet << endl;
        //result->Error("CLOSE_FAILURE", "关闭设备失败");
        result->Success(flutter::EncodableValue(lngRet));
    }

    return;
  }

  if (method_call.method_name().compare("getCashBalance") == 0) {
    std::cerr << "getCashBalance called 。。" << std::endl;
    if (pCashChanger == nullptr) {
      result->Error("Cash Changer not initialized");
      result->Success(flutter::EncodableValue("Cash Changer not initialized"));
      return;
    }

    // 定义变量
    BSTR st_CashCounts;
    VARIANT_BOOL b_Discrepancy;
    long lngRet;


    std::cerr << "ReadCashCounts execute 。。" << std::endl;
    // 调用 ReadCashCounts 方法
    lngRet = pCashChanger->ReadCashCounts(&st_CashCounts, &b_Discrepancy);
    std::cerr << "ReadCashCounts end 。。 " << lngRet << std::endl;
    // 检查是否成功
    if (lngRet != OposSuccess) {
       result->Success(flutter::EncodableValue("ReadCashCounts failed with code: " + to_string(lngRet)));
        return;
    }

    // 将 BSTR 转换为 std::string
    _bstr_t bstrCashCounts(st_CashCounts, false);
    string cashCounts = (const char*)bstrCashCounts;
    std::cerr << "将 BSTR 转换为 std::string 。。" << std::endl;
    // 分割硬币和纸币信息
    size_t i_FindIdx = cashCounts.find(';');
    string st_CoinCashList, st_BillCashList;
    if (i_FindIdx != string::npos) {
        st_CoinCashList = cashCounts.substr(0, i_FindIdx);
        st_BillCashList = cashCounts.substr(i_FindIdx + 1);
    } else {
        st_CoinCashList = cashCounts;
        st_BillCashList = "";
    }
    std::cerr << "分割硬币和纸币信息 。。" << std::endl;
    // 根据需要处理硬币和纸币信息
    // ...

    // 返回处理后的信息
    result->Success(flutter::EncodableValue("Coins: " + st_CoinCashList + "\nBills: " + st_BillCashList));
    return;
  }

  if(method_call.method_name().compare("startDeposit") == 0) {
    std::cerr << "dispenseCash called 。。" << std::endl;

    if (pCashChanger == nullptr) {
        result->Error("Cash Changer not initialized");
    }
    pCashChanger->DataEventEnabled = VARIANT_TRUE;
    long lngRet = pCashChanger->BeginDeposit();
    std::cerr << "BeginDeposit end 。。 " << lngRet << std::endl;
    if (lngRet == OposSuccess) {
        // 成功开始存款计数
        result->Success(flutter::EncodableValue("Deposit counting started successfully"));
    } else if (lngRet == OposEIllegal) {
        // 特定错误处理
        switch (pCashChanger->ResultCodeExtended) {
            case 225:
            
               result->Success(flutter::EncodableValue("Already in deposit counting 225"));
            case 226:
                // 已在计数中

                result->Success(flutter::EncodableValue("Already in deposit counting 226"));
            default:
                // 其他错误
                result->Success(flutter::EncodableValue("Error in starting deposit counting: " + to_string(pCashChanger->ResultCodeExtended)));
                
        }
    } else {
        // 通用错误处理
        result->Success(flutter::EncodableValue("Error in starting deposit counting: " + to_string(lngRet)));
        
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
