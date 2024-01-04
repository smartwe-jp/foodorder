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
      make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "cash_changer",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = make_unique<CashChangerPlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, move(result));
      });

  registrar->AddPlugin(move(plugin));
}

CashChangerPlugin::CashChangerPlugin() {

    cerr << "CashChangerPlugin construct" << endl;
    // 创建 COM 对象实例
    HRESULT hr = pCashChanger.CreateInstance(__uuidof(OPOSCashChanger));
    if (FAILED(hr)) {
        cerr << "创建 COM 实例失败" << endl;
        return;
    }
    // 初始化事件
    InitCashChangerEvents();
}

void CashChangerPlugin::InitCashChangerEvents () {
    cerr << "InitCashChangerEvents" << endl;
    
    HRESULT hr = pCashChanger->QueryInterface(IID_IConnectionPointContainer, (void**)&pCPC);

    if (SUCCEEDED(hr)) {
        
        hr = pCPC->FindConnectionPoint(DIID__IOPOSCashChangerEvents, &pCP);
        cerr << "FindConnectionPoint" << hr << endl;

        if (SUCCEEDED(hr)) {
            pHandler = new CashChangerEvents(); // 事件处理对象
            pHandler->setDelegate(this);
            
            assert(pHandler != nullptr);
            
            hr = pHandler->QueryInterface(DIID__IOPOSCashChangerEvents, (void**)&pEvents);
            if (SUCCEEDED(hr)) {
                // pHandler 实现了 _IOPOSCashChangerEvents 接口
                cerr << "pHandler 实现了 _IOPOSCashChangerEvents 接口" << hr << endl;
            } else {
                // pHandler 没有实现 _IOPOSCashChangerEvents 接口
                cerr << "pHandler 没有实现 _IOPOSCashChangerEvents 接口 failed" << hr << endl;
            }
            DWORD dwAdvise = 0;
            hr = pCP->Advise(pHandler, &dwAdvise);
            if (SUCCEEDED(hr)) {
                cerr << "Advise success: " << hr <<endl;
            } else {
                cerr << "Advise failed: " << hr << endl;
            }
        }
    }
    /*
    // 创建事件处理器对象
    CashChangerEvents* pEventHandler = new CashChangerEvents();

    IUnknown* pUnk;
    CoCreateInstance(CLSID_OPOSCashChanger, NULL, CLSCTX_INPROC_SERVER, IID_IUnknown, (void**)&pUnk);

    // 获取事件源接口
    pUnk->QueryInterface(IID_IOPOSCashChanger, (void**)&pCashChanger);

    // 获取连接点
    IConnectionPointContainer* pCPC;
    pCashChanger->QueryInterface(IID_IConnectionPointContainer, (void**)&pCPC);

    // 查找事件连接点
    IConnectionPoint* pCP;
    pCPC->FindConnectionPoint(DIID__IOPOSCashChangerEvents, &pCP);

    // 注册事件处理器
    DWORD dwCookie;
    HRESULT hr = pCP->Advise(pEventHandler, &dwCookie);
    if (SUCCEEDED(hr)) {
        cerr << "Advise success: " << hr <<endl;
    } else {
        cerr << "Advise failed: " << hr << endl;
    }
    */


}

CashChangerPlugin::~CashChangerPlugin() {
    cerr << "CashChangerPlugin destruct" << endl;

    // 释放 COM 对象
    if (pCashChanger) {
        pCashChanger->Release();
        pCashChanger = NULL;
    }

    // 释放事件连接点
    if (pCP) {
        pCP->Release();
        pCP = NULL;
    }

    // 释放连接点容器
    if (pCPC) {
        pCPC->Release();
        pCPC = NULL;
    }

    // 释放事件源
    if (pEvents) {
        pEvents->Release();
        pEvents = NULL;
    }


}

// Implements ICashChangerEventsDelegate
void CashChangerPlugin::DataEvent(long Status) {
    cerr << "------ CashChangerPlugin::DataEvent ------" << endl;
    cerr << "------ Status: " << Status << endl;
}

void CashChangerPlugin::DirectIOEvent(long EventNumber, long *pData, BSTR *pString) {
    cerr << "------ CashChangerPlugin::DirectIOEvent ------" << endl;
    cerr << "------ EventNumber: " << EventNumber << endl;
    cerr << "------ pData: " << pData << endl;
    cerr << "------ pString: " << pString << endl;
}

void CashChangerPlugin::StatusUpdateEvent(long Data) {
    cerr << "------ CashChangerPlugin::StatusUpdateEvent ------" << endl;
    cerr << "------ Data: " << Data << endl;
}

void CashChangerPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
 // 打开设备
 if (method_call.method_name().compare("openCashChanger") == 0) {
    cerr << "openCashChange called 。。" << endl;
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

                // 执行 DirectIO 
                long data = 0;
                BSTR bstr = SysAllocString(L"");
                lngRet = pCashChanger->DirectIO(CHAN_DI_DEPOSITMODE, &data, &bstr);
                SysFreeString(bstr);
                //InitCashChangerEvents();
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
    cerr << "closeCashChanger called 。。" << endl;

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
        result->Success(flutter::EncodableValue(lngRet));
    } else {
        cerr << "关闭设备失败，错误码：" << lngRet << endl;
        //result->Error("CLOSE_FAILURE", "关闭设备失败");
        result->Success(flutter::EncodableValue(lngRet));
    }

    return;
  }
  // 获取现金信息
  if (method_call.method_name().compare("getCashBalance") == 0) {
    cerr << "getCashBalance called 。。" << endl;
    if (pCashChanger == nullptr) {
      result->Error("Cash Changer not initialized");
      result->Success(flutter::EncodableValue("Cash Changer not initialized"));
      return;
    }

    // 定义变量
    BSTR st_CashCounts;
    VARIANT_BOOL b_Discrepancy;
    long lngRet;


    cerr << "ReadCashCounts execute 。。" << endl;
    // 调用 ReadCashCounts 方法
    lngRet = pCashChanger->ReadCashCounts(&st_CashCounts, &b_Discrepancy);
    cerr << "ReadCashCounts end 。。 " << lngRet << endl;
    // 检查是否成功
    if (lngRet != OposSuccess) {
       result->Success(flutter::EncodableValue("ReadCashCounts failed with code: " + to_string(lngRet)));
        return;
    }

    // 将 BSTR 转换为 string
    _bstr_t bstrCashCounts(st_CashCounts, false);
    string cashCounts = (const char*)bstrCashCounts;
    cerr << "将 BSTR 转换为 string 。。" << endl;
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
    cerr << "分割硬币和纸币信息 。。" << endl;
    // 根据需要处理硬币和纸币信息
    // ...

    // 返回处理后的信息
    result->Success(flutter::EncodableValue("Coins: " + st_CoinCashList + "\nBills: " + st_BillCashList));
    return;
  }

  // 开始入金
  if(method_call.method_name().compare("startDeposit") == 0) {
    cerr << "startDeposit called 。。" << endl;

    if (pCashChanger == nullptr) {
        result->Error("Cash Changer not initialized");
    }
    pCashChanger->DataEventEnabled = VARIANT_TRUE;
    long lngRet = pCashChanger->BeginDeposit();
    cerr << "startDeposit result 。。 " << lngRet << endl;
    if (lngRet == OposSuccess) {
        // 成功开始存款计数
        result->Success(flutter::EncodableValue(OposSuccess));
    } else if (lngRet == OposEIllegal) {
        // 特定错误处理
        switch (pCashChanger->ResultCodeExtended) {
            case OPOS_ECHAN_DEPOSIT:
                // 已在计数中
                cerr << "OPOS_ECHAN_DEPOSIT" << endl;
               result->Success(flutter::EncodableValue(0));
               break;
            case OPOS_ECHAN_PAUSEDEPOSIT:
                // 已在计数中
                cerr << "OPOS_ECHAN_PAUSEDEPOSIT" << endl;
                result->Success(flutter::EncodableValue(OPOS_ECHAN_PAUSEDEPOSIT));
                break;
            default:
                // 其他错误
                cerr << "其他错误:" << pCashChanger->ResultCodeExtended << endl;
                result->Success(flutter::EncodableValue(pCashChanger->ResultCodeExtended));
                
        }
    } else {
        // 通用错误处理
        result->Success(flutter::EncodableValue(lngRet));
        
    }

    return;
  }

 
  // 获取入金金额
  if(method_call.method_name().compare("depositAmount") == 0) {

    cerr << "DepositAmount called 。。" << endl;

    if (pCashChanger == nullptr) {
        result->Error("Cash Changer not initialized");
    }

    long logAmount;
    long lngRet;
    //int lngChange;
    //short intSuc;

    lngRet = pCashChanger->FixDeposit();
    cout << "FixDeposit result: " << lngRet << endl;
    if (lngRet == OposSuccess) {           
        // 获取入金金额
        logAmount = pCashChanger->DepositAmount;
        result->Success(flutter::EncodableValue(logAmount));
    } else {
        //result->Success(flutter::EncodableValue(lngRet));
        result->Error("Cash Changer ResultCode = " + to_string(lngRet));
        //result->Success(flutter::EncodableValue("Error in ending deposit counting: " + to_string(lngRet)));
    }

    return;
  }
   
  // 设置结束入金
  if(method_call.method_name().compare("endDeposit") == 0) {

    cerr << "endDeposit called 。。" << endl;

    if (pCashChanger == nullptr) {
        result->Error("Cash Changer not initialized");
    }
    auto arguments = method_call.arguments();
    if (!arguments) {
        cerr << "endDeposit param error 。。1" << endl;
        return;
    }
    
    int intSuc = 0;
    const auto *mapValue = get_if<flutter::EncodableMap>(arguments);
    auto it = mapValue->find(flutter::EncodableValue("end_deposit"));
    if (it == mapValue->end()) {
        cerr << "endDeposit param error 。。2" << endl;
        return;
    }

    intSuc = get<int>(it->second);
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
  if (method_call.method_name().compare("dispenseChange") == 0) {
    cerr << "dispenseChange called 。。" << endl;

    if (pCashChanger == nullptr) {
        result->Error("Cash Changer not initialized");
    }

    auto arguments = method_call.arguments();
    if (!arguments) {
        cerr << "dispenseChange param error 。。1" << endl;
        return;
    }
    const auto *mapValue = get_if<flutter::EncodableMap>(arguments);
    if (!mapValue) {
        cerr << "dispenseChange param error 。。2" << endl;
        return;
    }

    // Accessing a value in the map
    auto it = mapValue->find(flutter::EncodableValue("dispense"));
    if (it == mapValue->end()) {
        cerr << "dispenseChange param error 。。3" << endl;
        return;
    }

    long lngChange = get<int>(it->second);

    long lngRet = pCashChanger->DispenseChange(lngChange);
    cerr << "DispenseChange result 。。 " << lngRet << endl;
    if (lngRet == OposSuccess) {
        // 成功出钞
        result->Success(flutter::EncodableValue(lngRet));
    } else {
        // 其他错误
        result->Success(flutter::EncodableValue(lngRet));
    }
    
    return;
  }
  
  // 退还所有入金
  if (method_call.method_name().compare("depositRepay") == 0) {
    cerr << "depositRepay called .." << endl;

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

  if (method_call.method_name().compare("errorRestore") == 0) {
    cerr << "errorRestore called 。。" << endl;

    if (pCashChanger == nullptr) {
        result->Error("Cash Changer not initialized");
    }

    long lngRet = pCashChanger->ClearInput();

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
    
  // collect all
  if (method_call.method_name().compare("collectAll") == 0) {
    cerr << "collectAll called 。。" << endl;

    if (pCashChanger == nullptr) {
        result->Error("Cash Changer not initialized");
    }

    int lngRet;
    long lngData = 0;
    bool blnBill = false;
    bool blnCoin = false;

    //int lngChange = 0;
    auto arguments = method_call.arguments();
    if (!arguments) {
        cerr << "endDeposit param error 。。1" << endl;
        return;
    }
    const auto *mapValue = get_if<flutter::EncodableMap>(arguments);
    // Accessing a value in the map
    auto it = mapValue->find(flutter::EncodableValue("Bill"));
    if (it != mapValue->end()) {
        auto intValue = get_if<int>(&it->second);
        if (intValue != nullptr) {
            blnBill = *intValue == 1 ? true : false;
        } else {
            cerr << "checkErrorCode param error 。。2" << endl;
            return;
        }
        
    } else {
        cerr << "endDeposit param error 。。2" << endl;
        return;
    }

    auto it1 = mapValue->find(flutter::EncodableValue("Coin"));
    if (it1 != mapValue->end()) {
        lngData = get<int>(it1->second) == 1 ? true : false;
        auto intValue = get_if<int>(&it->second);
        if (intValue != nullptr) {
            blnCoin = *intValue == 1 ? true : false;
        } else {
            cerr << "checkErrorCode param error 。。2" << endl;
            return;
        }
    } else {
        cerr << "endDeposit param error 。。3" << endl;
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
    //gfncOposLog("DirectIO CHAN_DI_COLLECT", false, "結果コード：" + to_string(lngRet), "ClassName", "", "");

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

  if (method_call.method_name().compare("checkChangerStatus") == 0) {
    cerr << "checkChangerStatus called 。。" << endl;

    if (pCashChanger == nullptr) {
        result->Error("Cash Changer not initialized");
    }

    long lngRet = pCashChanger->CheckHealth(OposChInternal);
    cerr << "CheckHealth end 。。 " << lngRet << endl;
    if (lngRet == OposSuccess) {
        result->Success(flutter::EncodableValue(OposSuccess));
    } else {
        result->Success(flutter::EncodableValue(lngRet));
    }

    return;
  }


  // check error code

  if (method_call.method_name().compare("checkErrorCode") == 0) {
    cerr << "checkErrorCode called 。。" << endl;

    if (pCashChanger == nullptr) {
        result->Error("Cash Changer not initialized");
    }

    long lngData;
    int lngRet;
    // string strTemp;

    int mode = 1;
    auto arguments = method_call.arguments();
    if (!arguments) {
        cerr << "checkErrorCode param error 。。1" << endl;
        return;
    }
    const auto *mapValue = get_if<flutter::EncodableMap>(arguments);
    // Accessing a value in the map
    auto it = mapValue->find(flutter::EncodableValue("mode"));
    if (it != mapValue->end()) {
        mode = get<int>(it->second);
    } else {
        cerr << "checkErrorCode param error 。。2" << endl;
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
    //gfncOposLog("DirectIO CHAN_DI_STATUSREAD", false, "結果コード：" + to_string(lngRet), "ClassName", "", "");

    if (lngRet == OposSuccess) {
        // if (mode == 1) {
        //     checkErrorCode = stoi(strTemp.substr(39, 4));
        //     if (checkErrorCode < 1) {
        //         checkErrorCode = stoi(strTemp.substr(0, 4));
        //     }
        // } else {
        //     checkErrorCode = stoi(strTemp.substr(0, 4));
        // }
    }

    result->Success(flutter::EncodableValue(checkErrorCode));
    return;
  }
  
  


  if (method_call.method_name().compare("getPlatformVersion") == 0) {
        ostringstream version_stream;
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
