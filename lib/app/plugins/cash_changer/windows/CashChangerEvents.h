

#include <string>
#include "64OPOSCashChanger.tlh"

using namespace OposCashChanger_CCO;

class CashChangerEvents : public IDispatch {

public:
    
    CashChangerEvents(IOPOSCashChangerPtr pCashChanger) : pCashChanger(pCashChanger) {}

long m_refCount;

public:
    CashChangerEvents() : m_refCount(0) {}

    // IUnknown 方法
    HRESULT __stdcall QueryInterface(REFIID riid, void **ppv) override {
        if (!ppv) {
            return E_POINTER;
        }
        *ppv = nullptr;

        if (riid == IID_IUnknown || riid == IID_IDispatch) {
            *ppv = static_cast<IDispatch*>(this);
            AddRef();
            return S_OK;
        }

        return E_NOINTERFACE;
    }

    ULONG __stdcall AddRef() override {
        return InterlockedIncrement(&m_refCount);
    }

    ULONG __stdcall Release() override {
        long val = InterlockedDecrement(&m_refCount);
        if (val == 0) {
            delete this;
        }
        return val;
    }

    // IDispatch 方法
    HRESULT __stdcall GetTypeInfoCount(UINT *pctinfo) override {
        // 实现省略
        return S_OK;
    }

    HRESULT __stdcall GetTypeInfo(UINT iTInfo, LCID lcid, ITypeInfo **ppTInfo) override {
        // 实现省略
        return S_OK;
    }

    HRESULT __stdcall GetIDsOfNames(REFIID riid, LPOLESTR *rgszNames, UINT cNames,
                                    LCID lcid, DISPID *rgDispId) override {
        // 实现省略
        return S_OK;
    }

    HRESULT __stdcall Invoke(DISPID dispIdMember, REFIID riid, LCID lcid, WORD wFlags,
                             DISPPARAMS *pDispParams, VARIANT *pVarResult,
                             EXCEPINFO *pExcepInfo, UINT *puArgErr) override {
        // 你需要根据 dispIdMember 处理不同的事件
        switch (dispIdMember) {
            case 1:  // DataEvent的DISPID
                // 在这里处理 DataEvent，使用pDispParams->rgvarg访问参数
                DataEvent(pDispParams->rgvarg[0].lVal);
                break;
            case 2:  // DirectIOEvent的DISPID
                // 在这里处理 DirectIOEvent，确保参数的顺序和类型正确
                DirectIOEvent(pDispParams->rgvarg[2].lVal, 
                              pDispParams->rgvarg[1].plVal, 
                              pDispParams->rgvarg[0].pbstrVal);
                break;
            case 5:  // StatusUpdateEvent的DISPID
                // 在这里处理 StatusUpdateEvent
                StatusUpdateEvent(pDispParams->rgvarg[0].lVal);
                break;
            // 处理其他可能的DISPID
        }
        return S_OK;
    }


        // 实际的事件处理逻辑
    void DataEvent(long Status) {
        // 处理DataEvent事件
        printf("DataEvent: %d\n", Status);
    }

    void DirectIOEvent(long EventNumber, long* pData, BSTR* pString) {
        // 处理DirectIOEvent事件
        printf("DirectIOEvent: %d\n", EventNumber);
    }

    void StatusUpdateEvent(long Data) {
        // 处理StatusUpdateEvent事件
        printf("StatusUpdateEvent: %d\n", Data);
    }

private:
    IOPOSCashChangerPtr pCashChanger;
};

// // 在某个地方
// CashChangerEvents* events = new CashChangerEvents(pCashChanger);
// pCashChanger->Advise(events, &dwCookie); // 连接事件处理器