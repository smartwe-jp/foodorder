package com.hisanweb.flutter_plugin_msprinter;

import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.hardware.usb.UsbDevice;
import android.hardware.usb.UsbManager;
import android.os.Build;
import android.util.Log;

import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;

import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;

import com.hisanweb.flutter_plugin_msprinter.msprintsdk.HttpCallable;
import com.hisanweb.flutter_plugin_msprinter.msprintsdk.PrintCmd;
import com.hisanweb.flutter_plugin_msprinter.msprintsdk.UsbDriver;
import com.hisanweb.flutter_plugin_msprinter.orderInfo.OrderMenuList;

import com.alibaba.fastjson.JSONObject;
import com.hisanweb.flutter_plugin_msprinter.service.PrintService;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;


import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import static com.hisanweb.flutter_plugin_msprinter.msprintsdk.PrintCmd.PrintFeedDot;
import static com.hisanweb.flutter_plugin_msprinter.msprintsdk.PrintCmd.PrintDiskImageUrl;
import static com.hisanweb.flutter_plugin_msprinter.msprintsdk.PrintCmd.PrintDiskImagefile;
import static com.hisanweb.flutter_plugin_msprinter.msprintsdk.UtilsTools.data;
import static com.hisanweb.flutter_plugin_msprinter.msprintsdk.UtilsTools.hexStringToBytes;
import static com.hisanweb.flutter_plugin_msprinter.msprintsdk.UtilsTools.convertToBlackWhite;
import static com.hisanweb.flutter_plugin_msprinter.msprintsdk.UtilsTools.getBitmapParamsData;
import static com.hisanweb.flutter_plugin_msprinter.msprintsdk.UtilsTools.unicodeToUtf8;



/** FlutterPluginMsprinterPlugin */
public class FlutterPluginMsprinterPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;

  private Context mContext;

  public static Drawable drawable;
  public static Drawable sed;
  public static Drawable kanran;
  public static Drawable kanraneighty;
  public static Drawable sanfeng;
  public static Drawable sanfengeighty;
  public static Drawable rijindoujin;
  public static Drawable rijindoujineighty;

  private final String TAG = "PrintDemoUsb";
  private static final String ACTION_USB_PERMISSION = "com.usb.sample.USB_PERMISSION";
  private UsbDriver mUsbDriver;
  private UsbDevice mUsbDevice = null;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_plugin_msprinter");
    channel.setMethodCallHandler(this);
    mContext = flutterPluginBinding.getApplicationContext();

    mUsbDriver = new UsbDriver((UsbManager) mContext.getSystemService(Context.USB_SERVICE), mContext);
    PendingIntent permissionIntent = PendingIntent.getBroadcast(mContext, 0, new Intent(ACTION_USB_PERMISSION), 0);
    mUsbDriver.setPermissionIntent(permissionIntent);

    kanran= ContextCompat.getDrawable(mContext,R.drawable.kanran);
    kanraneighty= ContextCompat.getDrawable(mContext,R.drawable.kanraneighty);
    sanfeng= ContextCompat.getDrawable(mContext,R.drawable.sanfeng);
    sanfengeighty= ContextCompat.getDrawable(mContext,R.drawable.sanfengeighty);
    rijindoujin= ContextCompat.getDrawable(mContext,R.drawable.rijindoujin);
    rijindoujineighty= ContextCompat.getDrawable(mContext,R.drawable.rijindoujineighty);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {

    PrintService print = new PrintService();
    int iDriverCheck_sendPrint = usbDriverCheck();
    switch (call.method) {
      case "sendPrint":
        String operdata = call.argument("operdata");
        String shopInfo = call.argument("shopInfo");
        String printPaperSize = call.argument("printPaperSize");
        String isQueryReceipt = call.argument("isQueryReceipt");

        OrderMenuList oh = JSONObject.parseObject(operdata, OrderMenuList.class);

        //int iDriverCheck_sendPrint = usbDriverCheck();
        if (iDriverCheck_sendPrint == -1 || iDriverCheck_sendPrint == 1) {
          result.error("40001","无法获得usb权限",null);
          return;
        }else{
          //甘蘭
          if(shopInfo.equals("kanran")){
            if(printPaperSize.equals("1")){
              if(isQueryReceipt.equals("1")){
                print.execute_print(mUsbDriver,oh,kanran,1);
                print.execute_printRreceipt(mUsbDriver,oh,kanran);
              }else{
                print.execute_print(mUsbDriver,oh,kanran,0);
              }

            }else{
              if(isQueryReceipt.equals("1")){
                print.execute_print_eighty(mUsbDriver,oh,kanraneighty,1);
                print.execute_printRreceipt_eighty(mUsbDriver,oh,kanraneighty);
              }else{
                print.execute_print_eighty(mUsbDriver,oh,kanraneighty,0);
              }

            }
          }else if(shopInfo.equals("sanfeng")){//sanfeng
            if(printPaperSize.equals("1")){
              if(isQueryReceipt.equals("1")){
                print.execute_print(mUsbDriver,oh,sanfeng,1);
                print.execute_printRreceipt(mUsbDriver,oh,sanfeng);
              }else{
                print.execute_print(mUsbDriver,oh,sanfeng,0);
              }

            }else{
              if(isQueryReceipt.equals("1")){
                print.execute_print_eighty(mUsbDriver,oh,sanfengeighty,1);
                print.execute_printRreceipt_eighty(mUsbDriver,oh,sanfengeighty);
              }else{
                print.execute_print_eighty(mUsbDriver,oh,sanfengeighty,0);
              }

            }
          }else if(shopInfo.equals("rijindoujin")){//sanfeng
            if(printPaperSize.equals("1")){
              if(isQueryReceipt.equals("1")){
                print.execute_print(mUsbDriver,oh,rijindoujin,1);
                print.execute_printRreceipt(mUsbDriver,oh,rijindoujin);
              }else{
                print.execute_print(mUsbDriver,oh,rijindoujin,0);
              }

            }else{
              if(isQueryReceipt.equals("1")){
                print.execute_print_eighty(mUsbDriver,oh,rijindoujineighty,1);
                print.execute_printRreceipt_eighty(mUsbDriver,oh,rijindoujineighty);
              }else{
                print.execute_print_eighty(mUsbDriver,oh,rijindoujineighty,0);
              }

            }
          }


          result.success("success");
        }


        break;
      case "getPrintStatus":
        int iDriverCheck = usbDriverCheck();
        if (iDriverCheck == -1) {
          result.success("-1");
        }

        if (iDriverCheck == 1) {
          result.success("-1");
        }
        int iStatus = getPrinterStatus(mUsbDevice);
        result.success(String.valueOf(iStatus));
        break;
      case "setPrintPaperSizefiftyeight":
        if (iDriverCheck_sendPrint == -1 || iDriverCheck_sendPrint == 1) {
          result.error("40002","无法获得usb权限",null);
          return;
        }

          byte[] bSendData;
          String strdata= "13 74 44 88 10";

          bSendData = hexStringToBytes(strdata);
          mUsbDriver.write(bSendData);
        //mUsbDriver.closeUsbDevice(mUsbDevice);
        //mUsbDriver.openUsbDevice(mUsbDevice);
          mUsbDriver.write(PrintCmd.PrintSelfcheck());

        result.success("success "+strdata);
        break;
      case "setPrintPaperSizeeighty":
        if (iDriverCheck_sendPrint == -1 || iDriverCheck_sendPrint == 1) {
          result.error("40002","无法获得usb权限",null);
          return;
        }

        byte[] bSendDataeighty;
        String strdataeighty= "13 74 44 88 30";

        bSendDataeighty = hexStringToBytes(strdataeighty);
        mUsbDriver.write(bSendDataeighty);
        //mUsbDriver.closeUsbDevice(mUsbDevice);
        //mUsbDriver.openUsbDevice(mUsbDevice);
        mUsbDriver.write(PrintCmd.PrintSelfcheck());

        result.success("success "+strdataeighty);
        break;
      case "setPrintPaperSizePrintTest":
        if (iDriverCheck_sendPrint == -1 || iDriverCheck_sendPrint == 1) {
          result.error("40002","无法获得usb权限",null);
          return;
        }

        mUsbDriver.write(PrintCmd.PrintSelfcheck());

        result.success("success ");
        break;
      case "getPlatformVersion":
        result.success("Android " + Build.VERSION.RELEASE);
        break;
      default: result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

    private void doPrint() {
    int iDriverCheck = usbDriverCheck();
    if (iDriverCheck == -1) {
      return;
    }

    if (iDriverCheck == 1) {
      return;
    }
    byte[] bSendData;
    String strdata = "1D 76 30 00 30 00 5D 00 00 00 00 00 00 00 00 00 00 00 03 FF C0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 3F FF F8 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 07 FF FF FF 80 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 07 FF FF FF 80 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 07 FF FF FF 80 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 1F FF FF FF C0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 FF FF FF FF E0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 03 F0 00 0F FF F0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 06 00 00 03 FF FE 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 06 00 00 03 FF FE 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 08 00 00 00 FF FF 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 08 00 00 00 FF FF 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 70 00 00 00 3F FF 80 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 01 00 00 00 00 1F FF 80 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 0F FF 80 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 07 FF C0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 07 FF C0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 07 FF C0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 07 FF C0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 FF F0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 7F FF FF 80 00 01 FE 00 00 00 00 3F C0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 7F FF FF 80 00 01 FE 00 00 00 00 3F C0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 7F FF FF 80 00 03 FE 00 00 00 00 3F C0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 7F FF FF 80 00 03 FE 00 00 00 00 7F C0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 7F FF FF 80 00 03 FE 00 00 00 00 7F C0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 7F FF FF 80 00 03 FC 00 00 00 00 7F C0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 FF C0 00 00 00 00 00 00 00 00 00 7F 80 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 FF C0 00 00 00 00 00 00 00 00 00 7F 80 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 FF C0 00 00 00 00 00 00 00 00 00 7F 80 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 FF C0 00 00 00 0F FC 00 FF F8 0F FF FC 07 FF F0 0F F0 7F C0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 FF C0 00 00 00 0F FC 00 FF F8 0F FF FC 07 FF F0 0F F0 7F C0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 FF 00 00 00 00 0F FC 07 FF FF 0F FF FC 3F FF F8 0F F3 FF E0 00 00 00 00 00 00 00 00 00 00 00 00 C0 00 00 30 C0 00 00 00 00 00 00 18 00 00 00 00 FF 00 00 00 00 0F F8 1F FF FF 1F FF FC FF FF FC 0F FF FF F0 00 00 00 30 00 30 00 00 00 00 00 00 E0 00 00 30 C0 00 00 33 06 00 00 1C 00 00 00 03 FF FF FE 03 C0 0F F8 1F F3 FF C0 FF 81 FF 8F FC 1F FF FF F0 00 00 00 30 07 F8 00 00 00 00 00 00 E0 00 00 71 C0 00 06 3B 1F 00 00 38 00 00 00 03 FF FF FE 03 C0 0F F8 FF C0 7F C0 FF 01 FF 03 FE 1F F0 3F F0 00 00 00 1F FC 30 00 01 80 00 00 60 E0 00 00 71 80 00 07 F3 F6 00 00 30 60 00 00 03 FF FF FE 03 C0 0F F8 FF C0 7F C0 FF 01 FF 03 FE 1F F0 3F F0 00 00 00 1C 30 30 00 01 80 00 00 30 C0 00 00 E1 80 C0 06 33 06 00 00 67 F0 00 00 03 FF FF FE 03 C0 0F F8 FF C0 7F C0 FF 01 FF 03 FE 1F F0 3F F0 00 00 00 18 30 30 00 00 C0 00 00 1C C0 00 00 C3 1F C0 06 33 06 00 00 FC E0 00 00 03 FF FF F0 0F C0 3F F9 FF C0 7F C0 FF 03 FC 03 FE 1F E0 3F F0 00 00 00 18 30 30 00 00 E0 00 00 1C C0 00 01 C7 F1 80 06 33 0C 00 01 C1 C0 00 00 03 FF FF F0 0F C0 3F F9 FF C1 FF C7 FF 03 FC 03 FE 1F E0 3F E0 00 00 00 18 30 30 00 00 60 00 00 0C C0 00 03 C6 33 00 06 33 6C 00 03 F3 80 00 00 03 FF 00 00 00 00 3F F1 FF FF FF C7 FF 0F FC 03 FE 1F E0 7F E0 00 00 00 18 37 B0 00 00 71 80 00 01 C0 00 07 CC 33 00 06 F3 3C 00 07 1F 00 00 00 0F FE 00 00 00 00 3F F1 FF FF FF C7 FF 0F FC 03 FC 1F E0 7F E0 00 00 00 1B FE 30 00 00 70 C0 00 01 80 C0 06 DB 30 00 07 F3 1C 00 0E 0E 00 00 00 0F FE 00 00 00 00 3F F3 FF 00 00 07 FE 0F F8 03 FC FF E0 7F E0 00 00 00 18 30 30 00 C0 00 60 00 01 9F C0 0C C3 BC 00 06 33 00 00 18 1F 80 00 00 0F FE 00 00 00 00 3F F3 FF 00 00 07 FE 0F F8 03 FC FF E0 7F E0 00 00 00 18 30 30 00 C0 00 38 00 3F F1 C0 18 C7 37 00 06 33 0F 00 00 39 C0 00 00 0F FE 00 00 00 00 3F F3 FF 00 00 07 FE 0F F8 03 FC FF E0 7F E0 00 00 00 18 30 30 00 D8 00 3C 01 F3 81 80 00 CE 33 80 06 33 FE 00 00 F8 F0 00 00 0F FE 00 00 00 00 7F F3 FF 00 00 07 FE 0F F8 03 FC FF C0 7F C0 00 00 00 18 31 B0 01 D8 00 1C 00 03 01 80 00 D8 31 C0 06 F3 06 00 01 DC 3C 00 00 0F FE 00 00 00 00 7F F3 FF 01 FF 0F FE 0F F8 0F F8 FF C0 7F C0 00 00 00 18 7F B0 01 D8 00 0C 00 03 01 80 00 F1 B0 C0 07 B3 C6 00 07 1C 1F 00 00 0F F8 00 00 00 00 7F 83 FF 03 FC 0F FE 0F F8 3F F8 FF C0 7F C0 00 00 00 1F F0 30 01 9C 00 00 00 07 01 80 01 C0 F0 00 0C 33 6C 00 1C 18 7F F0 00 1F FF FF E0 00 00 7F 81 FF DF FC 0F FF 0F FF 7F F1 FF C1 FF C0 00 00 00 30 30 30 01 8C 00 00 00 06 E1 80 00 C0 70 00 0C 33 6C 00 70 1F F3 00 00 1F FF FF E0 00 00 7F 81 FF FF F8 0F FF 83 FF FF 81 FF C1 FF C0 00 00 00 30 30 30 03 8C 03 00 00 06 73 80 00 06 3C 00 0C 33 3C 00 C7 F8 60 00 00 1F FF FF E0 00 00 7F 81 FF FF F8 0F FF 83 FF FF 81 FF C1 FF C0 00 00 00 30 30 30 07 86 03 00 00 0C 33 00 03 03 87 00 0C 33 18 00 00 38 60 00 00 1F FF FF E0 00 00 7F 81 FF FF F8 0F FF 83 FF FF 81 FF C1 FF C0 00 00 00 30 30 30 03 06 03 00 00 1C 33 00 03 61 C3 C0 0C 33 18 00 00 30 60 00 00 1F FF FF E0 00 00 FF 80 FF FF F0 0F FF 01 FF FF 01 FF 01 FF 00 00 00 00 60 30 30 03 03 01 80 00 18 03 00 03 60 C0 E0 18 33 3C 00 00 70 60 00 00 1F FF FF E0 00 00 FF 80 0F FE 00 07 FF 00 FF FC 01 FF 01 FF 00 00 00 00 60 30 30 00 03 81 80 00 30 03 00 07 30 00 60 18 33 7E 00 00 60 E0 00 00 00 00 00 00 00 00 FF 00 00 00 00 00 00 00 00 00 01 00 00 00 00 00 00 00 E0 30 30 00 01 E1 80 00 71 87 00 07 18 00 00 18 33 67 00 00 E0 C0 00 00 00 00 00 00 00 00 FF 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 C0 31 B0 00 00 79 C0 00 E0 C6 00 0E 0C 0C 00 31 B3 C3 C0 01 D8 C0 00 00 00 00 00 00 00 00 FF 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 01 80 30 F0 00 00 0F C0 01 C0 76 00 0E 07 0C 00 30 F3 C3 F0 03 8E C0 00 00 00 00 00 00 00 03 FF 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 03 00 30 70 00 00 00 00 03 80 3E 00 00 01 CE 00 60 73 80 00 06 07 C0 00 00 00 00 00 00 00 03 FF 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 30 00 00 00 00 06 00 1C 00 00 00 7E 00 00 33 00 00 0C 03 80 00 00 00 00 00 00 00 1F FE 00 00 00 00 1F F0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 1C 00 0C 00 00 00 00 00 00 00 00 00 38 01 80 00 00 00 00 00 00 00 1F FE 00 00 00 00 3F E0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 1F FC 00 00 00 00 FF E0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 1F FC 00 00 00 00 FF E0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 FF C0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 03 FF 80 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 03 FF 80 00 00 00 01 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 07 FF 80 00 21 E0 01 83 00 00 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 02 00 00 00 00 00 0F FF 00 00 3E 40 01 02 00 00 1E 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 02 00 00 00 00 00 0F FF 00 00 27 80 01 02 60 21 E4 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 3F F8 00 00 78 80 02 3F 80 10 48 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 01 00 00 00 00 00 7F F0 00 00 40 80 02 44 00 10 30 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 01 C0 00 00 00 01 FF E0 00 00 4F 80 1F 87 80 02 3E 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 01 C0 00 00 00 01 FF E0 00 00 F8 00 24 79 00 03 C2 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 C0 00 00 00 03 FF C0 00 00 A0 00 04 09 E0 12 44 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 E0 00 00 00 0F FF 00 00 00 47 E0 06 FF 03 E3 F4 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 E0 00 00 00 0F FF 00 00 00 FA 40 19 12 00 44 88 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 38 00 00 00 3F FC 00 00 03 24 80 68 1E 00 44 88 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 1F 00 00 03 FF F8 00 00 04 48 81 8B F0 00 47 E8 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 07 80 00 0F FF F0 00 00 18 91 00 11 20 00 49 10 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 07 80 00 0F FF F0 00 00 23 22 00 11 3C 00 89 10 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 03 FC 03 FF FF 80 00 00 04 42 00 12 20 00 9A A0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 03 FC 03 FF FF 80 00 00 18 84 00 23 C0 0F D2 60 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 FF FF FF FC 00 00 00 23 28 01 24 60 00 38 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 7F FF FF F0 00 00 00 0C 30 00 C8 18 00 07 8C 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 0F FF FF 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 FF E0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 FF E0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 FF E0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ";
    //bSendData = hexStringToBytes(strdata);
    //mUsbDriver.write(bSendData);
      printbmp();
      mUsbDriver.write(PrintCmd.SetClean());

    mUsbDriver.write(PrintCmd.SetReadZKmode(0));
    PrintFeedDot(30);
    StringBuilder m_sbData;
    m_sbData = new StringBuilder("店号：8888          机号：100001");
    mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));
    m_sbData = new StringBuilder("电话:0755-12345678");
    mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));
    //PrintFeedDot(20);
    m_sbData = new StringBuilder("收银：01-店长");
    mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));
    m_sbData = new StringBuilder("时间：" + data());
    mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));
    m_sbData = new StringBuilder("-------------------------------");
    mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));
    byte[] bByte = new byte[3];
    bByte[0] = 12;
    bByte[1] = 18;
    bByte[2] = 26;
    mUsbDriver.write(PrintCmd.SetHTseat(bByte, 3));

    m_sbData = new StringBuilder("代码");
    mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 1));
    mUsbDriver.write(PrintCmd.PrintNextHT());
    m_sbData = new StringBuilder("单价");
    mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 1));
    mUsbDriver.write(PrintCmd.PrintNextHT());
    m_sbData = new StringBuilder("数量");
    mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 1));
    mUsbDriver.write(PrintCmd.PrintNextHT());
    m_sbData = new StringBuilder("金额");
    mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));

    m_sbData = new StringBuilder("48572819");
    mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 1));
    mUsbDriver.write(PrintCmd.PrintNextHT());
    m_sbData = new StringBuilder("2.00");
    mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 1));
    mUsbDriver.write(PrintCmd.PrintNextHT());
    m_sbData = new StringBuilder("3.00");
    mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 1));
    mUsbDriver.write(PrintCmd.PrintNextHT());
    m_sbData = new StringBuilder("6.00");
    mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));
    m_sbData = new StringBuilder("怡宝矿泉水");
    mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));

    m_sbData = new StringBuilder("48572820");
    mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 1));
    mUsbDriver.write(PrintCmd.PrintNextHT());
    m_sbData = new StringBuilder("2.50");
    mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 1));
    mUsbDriver.write(PrintCmd.PrintNextHT());
    m_sbData = new StringBuilder("2.00");
    mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 1));
    mUsbDriver.write(PrintCmd.PrintNextHT());
    m_sbData = new StringBuilder("5.00");
    mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));
    m_sbData = new StringBuilder("百事可乐(罐装)");
    mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));

    m_sbData = new StringBuilder("-------------------------------");
    mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));
    m_sbData = new StringBuilder("合计：");
    mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 1));
    mUsbDriver.write(PrintCmd.PrintNextHT());
    mUsbDriver.write(PrintCmd.PrintNextHT());
    m_sbData = new StringBuilder("5.00");
    mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 1));
    mUsbDriver.write(PrintCmd.PrintNextHT());
    m_sbData = new StringBuilder("11.00");
    mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));

    m_sbData = new StringBuilder("优惠：");
    mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 1));
    mUsbDriver.write(PrintCmd.PrintNextHT());
    mUsbDriver.write(PrintCmd.PrintNextHT());
    mUsbDriver.write(PrintCmd.PrintNextHT());
    m_sbData = new StringBuilder(" 0.00");
    mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));

    m_sbData = new StringBuilder("应付：");
    mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 1));
    mUsbDriver.write(PrintCmd.PrintNextHT());
    mUsbDriver.write(PrintCmd.PrintNextHT());
    mUsbDriver.write(PrintCmd.PrintNextHT());
    m_sbData = new StringBuilder("11.00");
    mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));

    m_sbData = new StringBuilder("微信支付：");
    mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 1));
    mUsbDriver.write(PrintCmd.PrintNextHT());
    mUsbDriver.write(PrintCmd.PrintNextHT());
    mUsbDriver.write(PrintCmd.PrintNextHT());
    m_sbData = new StringBuilder("11.00");
    mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));

    m_sbData = new StringBuilder("找零：");
    mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 1));
    mUsbDriver.write(PrintCmd.PrintNextHT());
    mUsbDriver.write(PrintCmd.PrintNextHT());
    mUsbDriver.write(PrintCmd.PrintNextHT());
    m_sbData = new StringBuilder(" 0.00");
    mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));

    m_sbData = new StringBuilder("-------------------------------");
    mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));
    m_sbData = new StringBuilder("会员：");
    mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));
    m_sbData = new StringBuilder("券号：");
    mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));
    m_sbData = new StringBuilder("-------------------------------");
    mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));
    PrintFeedDot(20);
    m_sbData = new StringBuilder("手机易捷通：ejeton.com.cn ");
    mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));
    m_sbData = new StringBuilder("客户热线：400-6088-160");
    mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));
    m_sbData = new StringBuilder("微信号：ejeton ");
    mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));
    m_sbData = new StringBuilder("http://weixin.qq.com/r/R3VZQQDEi130rUQi9yBV");
    mUsbDriver.write(PrintCmd.PrintQrcode(m_sbData.toString(), 10, 5, 0));
    mUsbDriver.write(PrintCmd.PrintFeedline(5));
    mUsbDriver.write(PrintCmd.PrintCutpaper(0));
  }

  /**
   * 获取usb权限
   */
  private int usbDriverCheck() {
    int iResult = -1;
    try {

      if (!mUsbDriver.isUsbPermission()) {
        UsbManager manager = (UsbManager) mContext.getSystemService(Context.USB_SERVICE);
        HashMap<String, UsbDevice> deviceList = manager.getDeviceList();
        mUsbDevice = null;
        Iterator<UsbDevice> deviceIterator = deviceList.values().iterator();
        while (deviceIterator.hasNext()) {
          UsbDevice device = deviceIterator.next();
          if ((device.getProductId() == 8211 && device.getVendorId() == 1305)
                  || (device.getProductId() == 8213 && device.getVendorId() == 1305)) {
            mUsbDevice = device;
            Log.d(TAG,"DeviceClass:" + device.getDeviceClass() + ";DeviceName:" + device.getDeviceName());
          }
        }
        if (mUsbDevice != null) {
          iResult = 1;
          if (mUsbDriver.usbAttached(mUsbDevice)) {
            if (mUsbDriver.openUsbDevice(mUsbDevice))
              iResult = 0;
          }
        }
      } else {
        if (!mUsbDriver.isConnected()) {
          if (mUsbDriver.openUsbDevice(mUsbDevice))
            iResult = 0;
        } else {
          iResult = 0;
        }
      }
    } catch (Exception e) {
      Log.e(TAG, "usbDriverCheck:" + e.getMessage());
    }

    return iResult;
  }


  // 检测打印机状态
  private int getPrinterStatus(UsbDevice usbDev) {
    int iRet = -1;

    byte[] bRead1 = new byte[1];
    byte[] bWrite1 = PrintCmd.GetStatus1();
    if (mUsbDriver.read(bRead1, bWrite1, usbDev) > 0) {
      iRet = PrintCmd.CheckStatus1(bRead1[0]);
    }

    if (iRet != 0)
      return iRet;

    byte[] bRead2 = new byte[1];
    byte[] bWrite2 = PrintCmd.GetStatus2();
    if (mUsbDriver.read(bRead2, bWrite2, usbDev) > 0) {
      iRet = PrintCmd.CheckStatus2(bRead2[0]);
    }

    if (iRet != 0)
      return iRet;

    byte[] bRead3 = new byte[1];
    byte[] bWrite3 = PrintCmd.GetStatus3();
    if (mUsbDriver.read(bRead3, bWrite3, usbDev) > 0) {
      iRet = PrintCmd.CheckStatus3(bRead3[0]);
    }

    if (iRet != 0)
      return iRet;

    byte[] bRead4 = new byte[1];
    byte[] bWrite4 = PrintCmd.GetStatus4();
    if (mUsbDriver.read(bRead4, bWrite4, usbDev) > 0) {
      iRet = PrintCmd.CheckStatus4(bRead4[0]);
    }
    return iRet;
  }


  private void printbmp(){

    int width,heigh;
    Bitmap bitmap = null;
    BitmapDrawable bd = (BitmapDrawable) sed;
    bitmap = bd.getBitmap();
    bitmap = convertToBlackWhite(bitmap);
    width = bitmap.getWidth();
    heigh = bitmap.getHeight();
    int iDataLen = width * heigh;
    int[] pixels = new int[iDataLen];
    bitmap.getPixels(pixels, 0, width, 0, 0, width, heigh);
    int[] data1 = pixels;
    mUsbDriver.write(PrintDiskImagefile(data1, width, heigh));
  }
}
