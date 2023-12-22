

#include <string>
#include "64OPOSCashChanger.tlh"

using namespace OposCashChanger_CCO;

class CashChangerEvents {




public:
    // 纯虚函数，没有实现
    virtual void doSomething() = 0;

    // 另一个纯虚函数，带有参数和返回值
    virtual int calculateSomething(int a, int b) = 0;

    // 带有默认实现的虚函数
    virtual void doSomethingElse() {
        // 默认实现
    }
    
    //CashChangerEvents(IOPOSCashChangerPtr pCashChanger) : pCashChanger(pCashChanger) {}

    // 实现 _IOPOSCashChangerEvents 接口的方法
    // HRESULT __stdcall DataEvent(long Status) override;

    // HRESULT __stdcall DirectIOEvent(long EventNumber, long* pData, BSTR* pString) override {
    //     // 处理 DirectIOEvent...
    //     return S_OK;
    // }

    // HRESULT __stdcall StatusUpdateEvent(long Data) override {
    //     if (!ERR_AUTO.Checked) return S_OK;

    //     short iErrCode;
    //     int lngData;
    //     int lngRet;
    //     std::string strTemp;
    //     if (Data == ChanStatusJam) {
    //         iErrCode = CheckErrorCode();
    //         if (iErrCode > 0) {
    //             //lngData = 1;
    //             //strTemp = GetErrGuidancePos();
    //             //gfncOposLog("DirectIO CHAN_DI_ERRGUIDANCE", true, "", this->Name, "", "");
    //             //lngRet = pCashChanger->DirectIO(CHAN_DI_ERRGUIDANCE, lngData, strTemp);
    //             //gfncOposLog("DirectIO CHAN_DI_ERRGUIDANCE", false, "Result code: " + std::to_string(lngRet), this->Name, "", "");
    //         }
    //     }

    //     return S_OK;
    // }

    // 实现 IDispatch 接口的方法
    // ...

private:
    IOPOSCashChangerPtr pCashChanger;
};

// // 在某个地方
// CashChangerEvents* events = new CashChangerEvents(pCashChanger);
// pCashChanger->Advise(events, &dwCookie); // 连接事件处理器