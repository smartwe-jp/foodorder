package com.paycube.paycube;

import androidx.annotation.NonNull;


import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/*------插件引入-------*/
import android.content.BroadcastReceiver;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Handler;
import android.os.Looper;

import java.nio.ByteBuffer;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Date;
import java.util.Objects;

import java.util.concurrent.ConcurrentLinkedQueue;


import sg.api.COMLib;
import sg.api.ReceiveEventListener;
import sg.api.ReceiveEventNotify;
import sg.common.COMLibImpl;
import sg.common.Log;
import sg.common.ReceiveEvent;
import sg.common.ReceiveEventNotifyImpl;
import sg.exception.COMException;


/**
 * PaycubePlugin
 */
public class PaycubePlugin implements FlutterPlugin, MethodCallHandler {
    private MethodChannel channel;
    private ReceiveEventListener chargingStateChangeReceiver;
    private Handler handler;
    private int count = 0;



    /***插件****/
    static COMLib lib = null;
    int seqNo = 0;
    int openCnt = 0;
    String putMoney = "0";
    String putCurrency = "";
    String listenOutMoney = "0";
    String machineStatus = "10"; //10关闭状态  20 可投币  30异常
    String currencyString = ""; //币种 截取0B 81的43位开始
     StringBuilder str = new StringBuilder();

     //监听几种状态
    String _payCubeAllowCashStatus = "Error";
    String _payCubeStopCashStatus = "Error";
    String _payCubeOutMoneyStatus = "Error";
    String _payCubeEndTradeStatus = "Error";

    ConcurrentLinkedQueue<ReceiveEvent> events = new ConcurrentLinkedQueue<>();


    ReceiveEventNotify listener = new ReceiveEventNotifyImpl();

    /***插件****/


    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "paycube");
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("getPlatformVersion")) {
            result.success("Android " + android.os.Build.VERSION.RELEASE);
        } else if (call.method.equals("startOpenPayCube")) {
            String operEvent = call.argument("operEvent");
            if (operEvent.equals("openPayCube")) {
                try {
                    if (lib == null) {
                        lib = new COMLibImpl();
                        lib.open("/dev/ttyS4");
                    }

                    //Log.logger.info("-----------------现金机 open开始 注册监听器------------------ ");
                    listener.setListener(new ReceiveEventListener() {
                        public void dataReceived(final ReceiveEvent event) {
                            final Handler mainHandler = new Handler(Looper.getMainLooper());
                            mainHandler.post(new Runnable() {
                                @Override
                                public void run() {
                                    byte[] arraye = (byte[]) event.getReceiveData();
                                    events.add(event);
                                    /*获取机器通信*/
                                    StringBuffer stringBuffero = new StringBuffer();
                                    //String receiveStr = "";
                                    for(int i = 0; i < arraye.length; ++i) {
                                        if (i % 16 == 0) {
                                            //stringBuffero = new StringBuffer();
                                            // stringBuffero.append(String.format("%03X0 ", (byte)(i / 15)));
                                        }
                                        stringBuffero.append(String.format("%02X ", arraye[i]));
                                        if (i % 16 == 15) {
                                            //stringBuffero = new StringBuffer();
                                        }
                                    }
                                    String receiveStr = stringBuffero.toString();

                                    if (event.getReceiveData()[1] == (byte) 0x06 && event.getReceiveData()[2] == (byte) 0x0A) {
                                        if(event.getReceiveData()[3] == (byte) 0x01){
                                            //入金许可监听状态
                                            if(_payCubeAllowCashStatus != "AllowSuccess"){
                                                if(event.getReceiveData()[6] == (byte) 0x00 && event.getReceiveData()[7] == (byte) 0x00){
                                                    _payCubeAllowCashStatus = "AllowSuccess";
                                                }else{
                                                    String[] AllowArray = receiveStr.split(" ");
                                                    _payCubeAllowCashStatus = "Error-"+AllowArray[6]+"--"+AllowArray[7];
                                                }
                                            }
                                        }else if(event.getReceiveData()[3] == (byte) 0x02){
                                            //入金禁止监听状态
                                            if(_payCubeStopCashStatus != "StopSuccess"){
                                                if(event.getReceiveData()[6] == (byte) 0x00 && event.getReceiveData()[7] == (byte) 0x00){
                                                    _payCubeStopCashStatus = "StopSuccess";
                                                }else{
                                                    String[] AllowArray = receiveStr.split(" ");
                                                    _payCubeStopCashStatus = "Error-"+AllowArray[6]+"--"+AllowArray[7];
                                                }
                                            }
                                            //channel.invokeMethod("onEndServiceChange",_payCubeStopCashStatus);
                                            // 当监听的服务发生变化时，调用_sendToFlutter向Flutter端发送通知
                                            _sendToFlutter("onEndServiceChange",_payCubeStopCashStatus);

                                        }else if(event.getReceiveData()[3] == (byte) 0x03){
                                            //取引终了监听状态
                                            if(_payCubeEndTradeStatus != "EndSuccess"){
                                                if(event.getReceiveData()[6] == (byte) 0x00 && event.getReceiveData()[7] == (byte) 0x00){
                                                    _payCubeEndTradeStatus = "EndSuccess";
                                                }else{
                                                    String[] AllowArray = receiveStr.split(" ");
                                                    _payCubeEndTradeStatus = "Error-"+AllowArray[6]+"--"+AllowArray[7];
                                                }
                                            }
                                            _sendToFlutter("onEndTradeServiceChange",_payCubeEndTradeStatus);
                                        }

                                    } else if (event.getReceiveData()[1] == (byte) 0x06 && event.getReceiveData()[2] == (byte) 0x0B && event.getReceiveData()[3] == (byte) 0x01) {
                                        //出金金额监听状态
                                        if(_payCubeOutMoneyStatus != "OutSuccess"){
                                            if(event.getReceiveData()[6] == (byte) 0x00 && event.getReceiveData()[7] == (byte) 0x00){
                                                _payCubeOutMoneyStatus = "OutSuccess";
                                            }else{
                                                String[] AllowArray = receiveStr.split(" ");
                                                _payCubeOutMoneyStatus = "Error-"+AllowArray[6]+"--"+AllowArray[7];
                                            }
                                        }
                                        _sendToFlutter("onPayOutServiceChange",_payCubeOutMoneyStatus);

                                    } else if (event.getReceiveData()[2] == (byte) 0x0A && (event.getReceiveData()[3] == (byte) 0x81 || event.getReceiveData()[3] == (byte) 0x82)) {
                                        //根据文档查找金额字符串，先判断是否有 4A 50 59（JPY），如果有则直接取后面四个字节，然后换算

                                        String findStr = "4A 50 59";
                                        if (receiveStr.contains(findStr)) {
                                            // 转成数组
                                            String[] strArray = receiveStr.split(" ");
                                            // 数组反转
                                            // 反转后的数组转成字符串，用空格隔开
                                            String coinMessage = strArray[12] + strArray[11] + strArray[10] + strArray[9];
                                            int ten = Integer.parseInt(coinMessage, 16);
                                            putMoney = String.valueOf(ten);

                                            _sendToFlutter("onGetPutMoneyStringChange",putMoney);
                                            //入金金额大于0后，说明允许投币了
                                            _payCubeAllowCashStatus = "AllowSuccess";
                                        }
                                        //入金币种
                                        if(event.getReceiveData()[3] == (byte) 0x82){
                                            if (receiveStr.length() >26) {
                                                //入金币种
                                                //putCurrency = ("".equals(putCurrency)) ? receiveStr.substring(24) : putCurrency + " "+receiveStr.substring(24);
                                                putCurrency = receiveStr.substring(26);

                                                _sendToFlutter("onGetPutMoneyCurrencyStringChange",putCurrency);
                                                Log.logger.info("入金币种字符串=======start");
                                                Log.logger.info(receiveStr);
                                                Log.logger.info("入金币种字符串=======middle");
                                                Log.logger.info(putCurrency);
                                                Log.logger.info("入金币种字符串=======end");
                                            }

                                        }

                                        // 入金金額コマンド
                                        try {
                                            ByteBuffer buf = ByteBuffer.allocate(6);
                                            buf.put(new byte[]{(byte) 0x00, (byte) 0x04});    // Len2
                                            buf.put(new byte[]{event.getReceiveData()[2], event.getReceiveData()[3]});    // Header
                                            buf.put(new byte[]{event.getReceiveData()[4], event.getReceiveData()[5]});
                                            // -- body --
                                            lib.write(buf.array());
                                            Log.logger.info("入金金額コマンド");
                                        } catch (Exception e) {
                                            Log.logger.error("入金金額コマンド受信Exception", e);
                                        }
                                    } else if (event.getReceiveData()[2] == (byte) 0x0C && event.getReceiveData()[3] == (byte) 0xA1) {
                                        //检测是否可以入金及机器是否关闭
                                        // 转成数组
                                        String[] MachineStatusArray = receiveStr.split(" ");
                                        if(MachineStatusArray.length >= 12 ){
                                            if((MachineStatusArray[8] == "20" || MachineStatusArray[8] == "50") && (MachineStatusArray[9] == "20" || MachineStatusArray[9] == "50") &&(MachineStatusArray[10] == "20" || MachineStatusArray[10] == "50")){
                                                machineStatus = "20";
                                            }else if(MachineStatusArray[8] == "A0" && MachineStatusArray[9] == "A0" && MachineStatusArray[10] == "A0"){
                                                machineStatus = "10--"+MachineStatusArray[8]+"--"+MachineStatusArray[9]+"--"+MachineStatusArray[10];
                                            }else{
                                                machineStatus = "30--"+MachineStatusArray[8]+"--"+MachineStatusArray[9]+"--"+MachineStatusArray[10];
                                            }
                                        }

                                
                                        // 機器状態通知
                                        try {
                                            ByteBuffer buf = ByteBuffer.allocate(6);
                                            buf.put(new byte[]{(byte) 0x00, (byte) 0x04});    // Len2
                                            buf.put(new byte[]{event.getReceiveData()[2], event.getReceiveData()[3]});    // Header
                                            buf.put(new byte[]{event.getReceiveData()[4], event.getReceiveData()[5]});
                                            // -- body --
                                            lib.write(buf.array());
                                            //Log.logger.error("機器状態通知受信");
                                        } catch (Exception e) {
                                            Log.logger.error("機器状態通知受信Exception", e);
                                        }
                                    }
                                    else if (event.getReceiveData()[2] == (byte) 0x0C && event.getReceiveData()[3] == (byte) 0x81) {
                                        // PM-10専用通知
                                        try {
                                            ByteBuffer buf = ByteBuffer.allocate(6);
                                            buf.put(new byte[]{(byte) 0x00, (byte) 0x04});    // Len2
                                            buf.put(new byte[]{event.getReceiveData()[2], event.getReceiveData()[3]});    // Header
                                            buf.put(new byte[]{event.getReceiveData()[4], event.getReceiveData()[5]});
                                            // -- body --
                                            lib.write(buf.array());
                                            Log.logger.error("PM-10専用通知");
                                        } catch (Exception e) {
                                            Log.logger.error("PM-10専用通知Exception", e);
                                        }
                                    } else if (event.getReceiveData()[2] == (byte) 0x0C && event.getReceiveData()[3] == (byte) 0x8A) {
                                        // 下位装置専用通知
                                        try {
                                            ByteBuffer buf = ByteBuffer.allocate(6);
                                            buf.put(new byte[]{(byte) 0x00, (byte) 0x04});    // Len2
                                            buf.put(new byte[]{event.getReceiveData()[2], event.getReceiveData()[3]});    // Header
                                            buf.put(new byte[]{event.getReceiveData()[4], event.getReceiveData()[5]});
                                            // -- body --
                                            lib.write(buf.array());
                                            //Log.logger.error("下位装置専用通知");
                                        } catch (Exception e) {
                                            Log.logger.error("下位装置専用通知Exception", e);
                                        }
                                    } 
                                    else if (event.getReceiveData()[2] == (byte) 0x0A && event.getReceiveData()[3] == (byte) 0x83) {

                                        // 入金詰まり貨幣通知
                                        try {
                                            ByteBuffer buf = ByteBuffer.allocate(6);
                                            buf.put(new byte[]{(byte) 0x00, (byte) 0x04});    // Len2
                                            buf.put(new byte[]{event.getReceiveData()[2], event.getReceiveData()[3]});    // Header
                                            buf.put(new byte[]{event.getReceiveData()[4], event.getReceiveData()[5]});
                                            // -- body --
                                            lib.write(buf.array());
                                            Log.logger.error("入金詰まり貨幣通知受信");
                                        } catch (Exception e) {
                                            Log.logger.error("入金詰まり貨幣通知受信Exception", e);
                                        }
                                    }  else if (event.getReceiveData()[2] == (byte) 0x0B && event.getReceiveData()[3] == (byte) 0x81) {
                                        // 出金情報
                                        // 出金金额

                                        Log.logger.info("-----------------现金机 0B 0B 01 出金金额开始------------------ "+receiveStr);
                                        String outfindStr = "4A 50 59";
                                        if (receiveStr.contains(outfindStr)) {
                                            String[] chuArray = receiveStr.split(" ");
                                            //Log.logger.info("-----------------现金机 0B 0B 01  出金金额开始转换------------------ "+chuArray[12] + chuArray[11] + chuArray[10] + chuArray[9]);
                                            // 数组反转
                                            // 反转后的数组转成字符串，用空格隔开
                                            String chuMessage = chuArray[12] + chuArray[11] + chuArray[10] + chuArray[9];
                                            int tenChu = Integer.parseInt(chuMessage, 16);
                                            listenOutMoney = String.valueOf(tenChu);

                                            //出金币种
                                            //currencyString = ("".equals(currencyString)) ? receiveStr.substring(42) : currencyString + " "+receiveStr.substring(42);
                                        }
                                        
                                        

                                        try {
                                            ByteBuffer buf = ByteBuffer.allocate(6);
                                            buf.put(new byte[]{(byte) 0x00, (byte) 0x04});    // Len2
                                            buf.put(new byte[]{event.getReceiveData()[2], event.getReceiveData()[3]});    // Header
                                            buf.put(new byte[]{event.getReceiveData()[4], event.getReceiveData()[5]});
                                            // -- body --
                                            lib.write(buf.array());
                                            Log.logger.error("出金情報");
                                        } catch (Exception e) {
                                            Log.logger.error("出金情報Exception", e);
                                        }
                                    } else if (event.getReceiveData()[2] == (byte) 0x0B && event.getReceiveData()[3] == (byte) 0x82) {
                                        // 出金終了
                                        Log.logger.info("-----------------现金机 0B 0B 01 出金金额开始------------------ "+receiveStr);
                                        String outfindStr = "4A 50 59";
                                        if (receiveStr.contains(outfindStr)) {
                                            //出金币种
                                            currencyString = ("".equals(currencyString)) ? receiveStr.substring(54) : currencyString + " "+receiveStr.substring(54);
                                            _sendToFlutter("getPayOutMoneyServiceChange",currencyString);
                                            Log.logger.info("出金币种字符串=======start");
                                            Log.logger.info(receiveStr);
                                            Log.logger.info("出金币种字符串=======middle");
                                            Log.logger.info(currencyString);
                                            Log.logger.info("出金币种字符串=======end");

                                        }
                                        
                                        try {
                                            ByteBuffer buf = ByteBuffer.allocate(6);
                                            buf.put(new byte[]{(byte) 0x00, (byte) 0x04});    // Len2
                                            buf.put(new byte[]{event.getReceiveData()[2], event.getReceiveData()[3]});    // Header
                                            buf.put(new byte[]{event.getReceiveData()[4], event.getReceiveData()[5]});
                                            // -- body --
                                            lib.write(buf.array());
                                            Log.logger.error("出金終了");
                                        } catch (Exception e) {
                                            // Do Nothing
                                            Log.logger.error("出金終了Exception", e);
                                        }
                                    }

                                    try {
                                        Thread.sleep(200);
                                    } catch (Exception e) {
                                        e.printStackTrace();
                                    }

                                    if (lib != null) {
                                        lib.setReceiveEventEnable(true);
                                    }
                                }
                            });
                        }
                    });

                    result.success("success");
                } catch (Exception e) {
                    Log.logger.error("现金机打开Exception", e);
                }
                
            } else if (operEvent.equals("CheckPayCubeStatus")) {
                // -- body --
                if (lib == null) {
                    result.success("openError");
                    return;
                }

                result.success("openSuccess");
            } else if (operEvent.equals("StartPayCubeMoney")) {
                // -- body --
                if (lib == null) {
                    result.success("startError");
                    return;
                }
                putMoney = "0";
                currencyString = "";
                putCurrency = "";
                _payCubeEndTradeStatus = "Error";
                // 入金許可
                byte[] seqNo = getSeqNo();
                doBeginDeposit(seqNo);

                result.success("startSuccess");
            } else if (operEvent.equals("getPayCubeAllowCashStatus")) {
                //入金许可监听
                result.success(_payCubeAllowCashStatus);
            }else if (operEvent.equals("getPayCubeStopCashStatus")) {
                //入金禁止监听
                result.success(_payCubeStopCashStatus);
            }else if (operEvent.equals("getPayCubeOutMoneyStatus")) {
                //出金监听
                result.success(_payCubeOutMoneyStatus);
            }else if (operEvent.equals("getPayCubeEndTradeStatus")) {
                //取引终了
                result.success(_payCubeEndTradeStatus);
            } else if (operEvent.equals("getPayCubeMoney")) {
                //返回投入金额
                // -- body --

                result.success(putMoney);
            } else if (operEvent.equals("getPayCubeOutMoney")) {
                //出金额;
                // -- body --
                result.success(listenOutMoney);
                
            } else if (operEvent.equals("getPayCubeMachineStatus")) {
                //机器状态;
                // -- body --
                result.success(machineStatus);
            } else if (operEvent.equals("getPayCubeOutMoneyCurrency")) {
                //返回币种枚数字符串;
                // -- body --
                if(currencyString.length() >= 70 ){
                    currencyString = currencyString.substring(63);
                }
                result.success(currencyString);
            } else if (operEvent.equals("getPayCubePutMoneyCurrency")) {
                //返回入金币种枚数字符串;
                // -- body --
                result.success(putCurrency);
            } else if (operEvent.equals("setReceiveEventStatus")) {
                //现金机 Setreceive;
                // -- body --
                if (lib == null) {
                    return;
                }

                lib.setReceiveEventEnable(true);

                result.success("success");
            }  else if (operEvent.equals("outPayCubeMoney")) {
               //现金机 出金开始;
                // -- body --

                String outMo = call.argument("outMoney");
                int outMoney = Integer.parseInt(outMo);

                try {
                    if (lib == null) {
                        //message.setText("null");
                        result.success("outMoneyError");
                        return;
                    }
                    ByteBuffer buf = ByteBuffer.allocate(13);
                    buf.put(new byte[]{(byte) 0x00, (byte) 0x0B});    // Len2
                    buf.put(new byte[]{(byte) 0x0B, (byte) 0x01});    // Header
                    buf.put(getSeqNo());
                    // -- body --
                    buf.put(new byte[]{(byte) 0x4A, (byte) 0x50, (byte) 0x59});    // "JPY"
                    //buf.put(new byte[]{(byte) 0x01, (byte) 0x00, (byte) 0x00, (byte) 0x00});    // amount=1

                    byte[] data = new byte[4];
                    data[3] = (byte) (outMoney >> 24);
                    data[2] = (byte) (outMoney >> 16 & 0xFF);
                    data[1] = (byte) (outMoney >> 8 & 0xFF);
                    data[0] = (byte) (outMoney & 0xFF);

                    buf.put(data);
                    Log.logger.info("-----------------现金机 取引终了开结束----------------- "+outMoney);
                    lib.write(buf.array());

                    result.success("outMoneySuccess");
                } catch (COMException e) {
                }



            } else if (operEvent.equals("endPayCube")) {
                //入金禁止
                try {
                    if (lib == null) {
                        result.success("endsuccess");
                        return;
                    }
                    ByteBuffer buf = ByteBuffer.allocate(6);
                    buf.put(new byte[]{(byte) 0x00, (byte) 0x04});    // Len2
                    buf.put(new byte[]{(byte) 0x0A, (byte) 0x02});    // Header
                    buf.put(getSeqNo());
                    lib.write(buf.array());


                    result.success("endsuccess");
                    //lib.setReceiveEventEnable(false);
                } catch (COMException e) {
                    e.printStackTrace();
                }

            } else if (operEvent.equals("endTradePayCube")) {
               // 取引终了;
                // -- body --
                try {
                    if (lib == null) {
                        result.success("endtradesuccess");
                        return;
                    }
                    ByteBuffer buf = ByteBuffer.allocate(6);
                    buf.put(new byte[]{(byte) 0x00, (byte) 0x04});    // Len2
                    buf.put(new byte[]{(byte) 0x0A, (byte) 0x03});    // Header
                    buf.put(getSeqNo());
                    lib.write(buf.array());


                    //lib.setReceiveEventEnable(false);

                    putMoney = "0";
                    listenOutMoney = "0";
                    //machineStatus = "10";


                    _payCubeAllowCashStatus = "Error";
                    _payCubeStopCashStatus = "Error";
                    _payCubeOutMoneyStatus = "Error";


                    //lib.close();
                    //listener.removeListener();
                    //lib = null;
                    
                    result.success("endtradesuccess");
                    
                } catch (COMException e) {
                    e.printStackTrace();
                    //result.success("endtradesuccess");
                }
                
                //Log.logger.info("-----------------现金机 取引终了开结束----------------- ");
            }else if (operEvent.equals("closePayCube")) {
                // Log.logger.info("-----------------现金机 取引终了开始------------------ ");
                // -- body --
                try {
                    if (lib == null) {
                        return;
                    }
                    lib.close();
                    listener.removeListener();
                    lib = null;
                    result.success("closePayCubesuccess");

                } catch (COMException e) {
                    e.printStackTrace();
                    //result.success("endtradesuccess");
                }

                //Log.logger.info("-----------------现金机 取引终了开结束----------------- ");
            } else if (operEvent.equals("prohibitOneCash")) {
                //禁止一块入金和出金
                try {
                    if (lib == null) {
                        result.success("prohibitOneCashsuccess");
                        return;
                    }

                    ByteBuffer buf = ByteBuffer.allocate(10);
                    buf.put(new byte[]{(byte) 0x00, (byte) 0x06});    // Len2
                    buf.put(new byte[]{(byte) 0x0C, (byte) 0x11});    // Header
                    buf.put(getSeqNo());
                    //入金
                    //buf.put(new byte[]{(byte) 0x4A, (byte) 0x50, (byte) 0x59});
                    buf.put(new byte[]{(byte) 0x61, (byte) 0x90});
                    buf.put(new byte[]{(byte) 0xA1, (byte) 0x40});
                    lib.write(buf.array());

                    //putMoney = "0";
                    result.success("prohibitOneCashsuccess");

                    //lib.setReceiveEventEnable(false);
                } catch (COMException e) {
                    e.printStackTrace();
                }

            } else if (operEvent.equals("allowOneCash")) {
                //允许一块入金和出金
                try {
                    if (lib == null) {
                        result.success("allowOneCashsuccess");
                        return;
                    }

                    ByteBuffer buf = ByteBuffer.allocate(10);
                    buf.put(new byte[]{(byte) 0x00, (byte) 0x06});    // Len2
                    buf.put(new byte[]{(byte) 0x0C, (byte) 0x11});    // Header
                    buf.put(getSeqNo());
                    //入金
                    //buf.put(new byte[]{(byte) 0x4A, (byte) 0x50, (byte) 0x59});
                    buf.put(new byte[]{(byte) 0x61, (byte) 0x10});
                    buf.put(new byte[]{(byte) 0xA1, (byte) 0x20});
                    lib.write(buf.array());

                    //putMoney = "0";
                    result.success("allowOneCashsuccess");

                    //lib.setReceiveEventEnable(false);
                } catch (COMException e) {
                    e.printStackTrace();
                }

            }
        } else {
            result.notImplemented();
        }
    }


    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    private void _sendToFlutter(String channelMethod,String message) {
        Log.logger.info(channelMethod+"android通信到flutter=======sendToFlutter");
        //if (channel != null) {
            channel.invokeMethod(channelMethod, message);
        //}
    }

    private void doBeginDeposit(byte[] seqNo) {
        try {
            if (lib == null) {
                Log.logger.info("doBeginDeposit lib is null");
                return;
            }
            ByteBuffer buf = ByteBuffer.allocate(14);
            buf.put(new byte[]{(byte) 0x00, (byte) 0x0C});    // Len2
            buf.put(new byte[]{(byte) 0x0A, (byte) 0x01});    // Header
            buf.put(seqNo);
            // -- body --
            buf.put(getCalendarHex());
            buf.put((byte) 0x01);
            lib.write(buf.array());
            Log.logger.info("入金開始設置完了");
        } catch (Exception e) {
            Log.logger.error("入金開始設置Exception", e);
        }
    }

    public byte[] getCalendarHex() {
        ByteBuffer ret = ByteBuffer.allocate(7);
        Calendar calender = Calendar.getInstance();

        // 年/月/日/時/分/秒に分解
        int year = calender.get(Calendar.YEAR);
        int month = calender.get(Calendar.MONTH);
        int day = calender.get(Calendar.DATE);
        int hour = calender.get(Calendar.HOUR_OF_DAY);
        int minute = calender.get(Calendar.MINUTE);
        int second = calender.get(Calendar.SECOND);
        ret.put((byte) (year / 256));
        ret.put((byte) (year % 256));
        ret.put((byte) (month + 1));   // calendarクラスでは1月=0と表される
        ret.put((byte) day);
        ret.put((byte) hour);
        ret.put((byte) minute);
        ret.put((byte) second);
        return ret.array();
    }


    public byte[] getSeqNo() {
        // seqNoを2byteに
        // SequenceNo取得
        seqNo++;
        if (seqNo == calcHextoInt(new byte[]{(byte) 0xFF, (byte) 0xFF})) {
            // 0xFFFEの次は0x0001
            seqNo = 1;
        }
        return new byte[]{(byte) (seqNo / 0xFF), (byte) (seqNo % 0xFF)};
    }

    long calcHextoInt(byte[] hex) {
        long val = 0;
        for (byte hex1 : hex) {
            val = (val << 8) + (hex1 & 0xff);
        }
        return val;
    }

}
