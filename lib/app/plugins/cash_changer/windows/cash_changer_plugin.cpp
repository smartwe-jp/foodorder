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
 // 打开设备
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
  // 关闭设备
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
  // 获取现金信息
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

  // 开始入金
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
            case OPOS_ECHAN_DEPOSIT:
            
               result->Success(flutter::EncodableValue("Already in deposit counting 225"));
            case OPOS_ECHAN_PAUSEDEPOSIT:
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


  // 获取入金金额
  if(method_call.method_name().compare("depositAmount") == 0) {

    std::cerr << "DepositAmount called 。。" << std::endl;

    if (pCashChanger == nullptr) {
        result->Error("Cash Changer not initialized");
    }

    any logAmount;
    int lngRet;
    int lngChange;
    short intSuc;

    lngRet = pCashChanger->FixDeposit();

    if (lngRet == OposSuccess) {
        // 获取入金金额
        logAmount = pCashChanger->DepositAmount;
        result->Success(flutter::EncodableValue(logAmount));
    } else {
        
        result->Error("Cash Changer ResultCode = " + to_string(lngRet));
        //result->Success(flutter::EncodableValue("Error in ending deposit counting: " + to_string(lngRet)));
    }

    return;
  }

  // 设置结束入金
  if(method_call.method_name().compare("endDeposit") == 0) {

    std::cerr << "endDeposit called 。。" << std::endl;

    if (pCashChanger == nullptr) {
        result->Error("Cash Changer not initialized");
    }
    auto arguments = method_call.arguments();
    if (!arguments) {
        std::cerr << "endDeposit param error 。。1" << std::endl;
        return;
    }
    const auto *mapValue = get_if<flutter::EncodableMap>(arguments);
    int intSuc = 0;
    // Accessing a value in the map
    auto it = mapValue->find(flutter::EncodableValue("end_deposit"));
    if (it != mapValue->end()) {
        intSuc = get<int>(it->second);
    } else {
        std::cerr << "endDeposit param error 。。2" << std::endl;
        return;
    }

    long lngRet = pCashChanger->EndDeposit(intSuc);

    if (lngRet == OposSuccess) {

      result->Success(flutter::EncodableValue(lngRet));

    } else {
      if (pCashChanger->ResultCodeExtended == OPOS_ECHAN_DEPOSIT) {
        result->Success(flutter::EncodableValue(OPOS_ECHAN_DEPOSIT));
      } else {
        result->Success(flutter::EncodableValue(pCashChanger->ResultCodeExtended));
      }
    }
    return;
  }

  // 出钞找钱
  if (method_call.method_name().compare("dispenseChange")) {
    std::cerr << "dispenseChange called 。。" << std::endl;

    if (pCashChanger == nullptr) {
        result->Error("Cash Changer not initialized");
    }

    int lngChange = 0;
    auto arguments = method_call.arguments();
    if (!arguments) {
        std::cerr << "endDeposit param error 。。1" << std::endl;
        return;
    }
    const auto *mapValue = get_if<flutter::EncodableMap>(arguments);
    int intSuc = 0;
    // Accessing a value in the map
    auto it = mapValue->find(flutter::EncodableValue("end_deposit"));
    if (it != mapValue->end()) {
        lngChange = get<int>(it->second);
    } else {
        std::cerr << "endDeposit param error 。。2" << std::endl;
        return;
    }

    long lngRet = pCashChanger->DispenseChange(lngChange);

    if (lngRet == OposSuccess) {
        // 成功出钞
        result->Success(flutter::EncodableValue(lngRet));
    } else {
        // 其他错误
        result->Success(flutter::EncodableValue(lngRet));
    }
    return;
  }

  // 退还所有入 
  if (method_call.method_name().compare("depositRepay")) {
    std::cerr << "depositRepay called 。。" << std::endl;

    if (pCashChanger == nullptr) {
        result->Error("Cash Changer not initialized");
    }

    long lngRet = pCashChanger->EndDeposit(ChanDepositrepay);

    if (lngRet == OposSuccess) {

      result->Success(flutter::EncodableValue(lngRet));

    } else {
      if (pCashChanger->ResultCodeExtended == OPOS_ECHAN_DEPOSIT) {
        result->Success(flutter::EncodableValue(OPOS_ECHAN_DEPOSIT));
      } else {
        result->Success(flutter::EncodableValue(pCashChanger->ResultCodeExtended));
      }
    }
    return;
  }

  //エラー解除ガイダンスを起動する

  if (method_call.method_name().compare("errorRestore")) {
    std::cerr << "errorRestore called 。。" << std::endl;

    // if (pCashChanger == nullptr) {
    //     result->Error("Cash Changer not initialized");
    // }

    // long lngRet = pCashChanger->ClearInput();

    // if (lngRet == OposSuccess) {

    //   result->Success(flutter::EncodableValue(lngRet));

    // } else {
    //   if (pCashChanger->ResultCodeExtended == OPOS_ECHAN_DEPOSIT) {
    //     result->Success(flutter::EncodableValue(OPOS_ECHAN_DEPOSIT));
    //   } else {
    //     result->Success(flutter::EncodableValue(pCashChanger->ResultCodeExtended));
    //   }
    // }
    return;
  }

  // collect all
  if (method_call.method_name().compare("collectAll")) {
    std::cerr << "collectAll called 。。" << std::endl;

    if (pCashChanger == nullptr) {
        result->Error("Cash Changer not initialized");
    }

    int lngRet;
    long lngData = 0;
    bool blnBill = false;
    bool blnCoin = false;

    int lngChange = 0;
    auto arguments = method_call.arguments();
    if (!arguments) {
        std::cerr << "endDeposit param error 。。1" << std::endl;
        return;
    }
    const auto *mapValue = get_if<flutter::EncodableMap>(arguments);
    // Accessing a value in the map
    auto it = mapValue->find(flutter::EncodableValue("Bill"));
    if (it != mapValue->end()) {
        lngChange = get<int>(it->second) == 1 ? true : false;
    } else {
        std::cerr << "endDeposit param error 。。2" << std::endl;
        return;
    }

    auto it1 = mapValue->find(flutter::EncodableValue("Coin"));
    if (it1 != mapValue->end()) {
        lngData = get<int>(it1->second) == 1 ? true : false;
    } else {
        std::cerr << "endDeposit param error 。。3" << std::endl;
        return;
    }

    if (blnBill != NULL && blnBill) {
        lngData = lngData | 0x3;
    }
    if (blnCoin != NULL && blnCoin) {
        lngData = lngData | 0x70000;
    }
    BSTR bstr = SysAllocString(L"");
    //gfncOposLog("DirectIO CHAN_DI_COLLECT", true, "", "ClassName", "", "");
    lngRet = pCashChanger->DirectIO(CHAN_DI_COLLECT, &lngData, &bstr);
    //gfncOposLog("DirectIO CHAN_DI_COLLECT", false, "結果コード：" + std::to_string(lngRet), "ClassName", "", "");

    switch (pCashChanger->ResultCode) {
        case OposSuccess:
  
            result->Success(flutter::EncodableValue(OposSuccess));
            break;
        case OposEExtended:
            switch (pCashChanger->ResultCodeExtended) {
                case OPOS_ECHAN_OVERDISPENSE:
                    //modFunc.menmErrStatus = GE_CASHCHANGER_ERROR_NOCHANGE;
                    result->Success(flutter::EncodableValue(OPOS_ECHAN_OVERDISPENSE));
                    break;
                case OPOS_ECHAN_OVER:
                    //modFunc.menmErrStatus = GE_CASHCHANGER_ERROR_OVER;
                    result->Success(flutter::EncodableValue(OPOS_ECHAN_OVER));
                    break;
                case OPOS_ECHAN_SETERROR:
                case OPOS_ECHAN_ERROR:
                case OPOS_ECHAN_BUSY:
                    //modFunc.menmErrStatus = GE_CASHCHANGER_ERROR_CHANGER;
                    result->Success(flutter::EncodableValue(pCashChanger->ResultCode));

                    break;
                default:
                    result->Success(flutter::EncodableValue(pCashChanger->ResultCode));
                    //modFunc.menmErrStatus = GE_CASHCHANGER_ERROR_ELSE;

            }
            break;
        default:
            result->Success(flutter::EncodableValue(pCashChanger->ResultCode));
            //modFunc.menmErrStatus = GE_CASHCHANGER_ERROR_ELSE;
    }
    return;
  }


  // check error code

  if (method_call.method_name().compare("checkErrorCode")) {
    std::cerr << "checkErrorCode called 。。" << std::endl;

    if (pCashChanger == nullptr) {
        result->Error("Cash Changer not initialized");
    }

    long lngData;
    int lngRet;
    // std::string strTemp;

    int mode = 1;
    auto arguments = method_call.arguments();
    if (!arguments) {
        std::cerr << "checkErrorCode param error 。。1" << std::endl;
        return;
    }
    const auto *mapValue = std::get_if<flutter::EncodableMap>(arguments);
    // Accessing a value in the map
    auto it = mapValue->find(flutter::EncodableValue("mode"));
    if (it != mapValue->end()) {
        mode = get<int>(it->second);
    } else {
        std::cerr << "checkErrorCode param error 。。2" << std::endl;
        return;
    }

    short checkErrorCode = 0;

    if (mode == 1) {
        lngData = 0x80; // 紙幣・硬貨両接続
    } else {
        lngData = 0x1; // 硬貨単体接続
    }

    //strTemp = "";
    BSTR strTemp = SysAllocString(L"");
    //gfncOposLog("DirectIO CHAN_DI_STATUSREAD", true, "", "ClassName", "", "");
    lngRet = pCashChanger->DirectIO(CHAN_DI_STATUSREAD, &lngData, &strTemp);
    //gfncOposLog("DirectIO CHAN_DI_STATUSREAD", false, "結果コード：" + std::to_string(lngRet), "ClassName", "", "");

    if (lngRet == OposSuccess) {
        // if (mode == 1) {
        //     checkErrorCode = std::stoi(strTemp.substr(39, 4));
        //     if (checkErrorCode < 1) {
        //         checkErrorCode = std::stoi(strTemp.substr(0, 4));
        //     }
        // } else {
        //     checkErrorCode = std::stoi(strTemp.substr(0, 4));
        // }
    }

    result->Success(flutter::EncodableValue(checkErrorCode));
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
