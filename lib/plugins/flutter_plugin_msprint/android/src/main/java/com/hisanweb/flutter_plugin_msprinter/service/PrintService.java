package com.hisanweb.flutter_plugin_msprinter.service;

import static com.hisanweb.flutter_plugin_msprinter.msprintsdk.PrintCmd.PrintDiskImagefile;
import static com.hisanweb.flutter_plugin_msprinter.msprintsdk.PrintCmd.PrintFeedDot;
import static com.hisanweb.flutter_plugin_msprinter.msprintsdk.UtilsTools.convertToBlackWhite;
import static com.hisanweb.flutter_plugin_msprinter.msprintsdk.UtilsTools.data;

import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.hardware.usb.UsbDevice;
import android.hardware.usb.UsbManager;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;

import com.hisanweb.flutter_plugin_msprinter.FlutterPluginMsprinterPlugin;
import com.hisanweb.flutter_plugin_msprinter.R;
import com.hisanweb.flutter_plugin_msprinter.msprintsdk.HttpCallable;
import com.hisanweb.flutter_plugin_msprinter.msprintsdk.PrintCmd;
import com.hisanweb.flutter_plugin_msprinter.msprintsdk.UsbDriver;
import com.hisanweb.flutter_plugin_msprinter.orderInfo.CategoryVos;
import com.hisanweb.flutter_plugin_msprinter.orderInfo.LineVos;
import com.hisanweb.flutter_plugin_msprinter.orderInfo.OptionVos;
import com.hisanweb.flutter_plugin_msprinter.orderInfo.OrderMenuList;

import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class PrintService  {

    public void execute_printRreceipt(UsbDriver mUsbDriver,OrderMenuList oh,Drawable sed){

        /*String imgUrl = "https://images.gutingjun.com/upload/sed.bmp";


        ExecutorService newCachedThreadPool = Executors.newCachedThreadPool();

        try{
            Future<byte[]> future = newCachedThreadPool.submit(new HttpCallable(imgUrl));
            byte[] result = future.get();
            mUsbDriver.write(result);
        }catch (Exception e){
            System.out.println("http Exception");
        }*/

        printbmp(mUsbDriver,sed);

        mUsbDriver.write(PrintCmd.PrintFeedline(2));
        mUsbDriver.write(PrintCmd.SetClean());

        mUsbDriver.write(PrintCmd.SetReadZKmode(0));
        //mUsbDriver.write(PrintCmd.SetCodepage(8,0));
        PrintFeedDot(30);
        StringBuilder m_sbData;


        mUsbDriver.write(PrintCmd.SetAlignment(0));
        m_sbData = new StringBuilder(oh.getOrderDate());
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));
        mUsbDriver.write(PrintCmd.PrintFeedline(1));

        mUsbDriver.write(PrintCmd.SetSizetext(1,1));
        mUsbDriver.write(PrintCmd.SetAlignment(1));
        m_sbData = new StringBuilder("領収書");
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));
        mUsbDriver.write(PrintCmd.SetAlignment(0));
        mUsbDriver.write(PrintCmd.SetClean());

        //设置行间距
        mUsbDriver.write(PrintCmd.SetReadZKmode(3));


        mUsbDriver.write(PrintCmd.PrintFeedline(1));


        //mUsbDriver.write(PrintCmd.SetUnderline(1));

        mUsbDriver.write(PrintCmd.SetAlignment(2));
        mUsbDriver.write(PrintCmd.SetBold(1)); //加粗
        m_sbData = new StringBuilder("￥"+oh.getPayPrice()+"  ");
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));
        m_sbData = new StringBuilder("--------------------------------");
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));
        mUsbDriver.write(PrintCmd.PrintFeedline(1));
        mUsbDriver.write(PrintCmd.SetUnderline(0));

        mUsbDriver.write(PrintCmd.SetClean());
        //m_sbData = new StringBuilder("--------------------");
        //mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));

        mUsbDriver.write(PrintCmd.PrintFeedline(1));


        byte[] bByte = new byte[1];
        bByte[0] = 28;
        //bByte[1] = 10;
        mUsbDriver.write(PrintCmd.SetHTseat(bByte, 1));


        mUsbDriver.write(PrintCmd.SetAlignment(0));
        m_sbData = new StringBuilder("税抜金額");
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 1));
        mUsbDriver.write(PrintCmd.PrintNextHT());
        mUsbDriver.write(PrintCmd.PrintNextHT());
        mUsbDriver.write(PrintCmd.SetAlignment(2));
        m_sbData = new StringBuilder(oh.getExcludingTax());
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));

        //设置行间距
        mUsbDriver.write(PrintCmd.SetReadZKmode(3));

        mUsbDriver.write(PrintCmd.SetAlignment(0));
        m_sbData = new StringBuilder("消費税");
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 1));
        mUsbDriver.write(PrintCmd.PrintNextHT());
        mUsbDriver.write(PrintCmd.PrintNextHT());
        mUsbDriver.write(PrintCmd.SetAlignment(2));
        m_sbData = new StringBuilder(oh.getTax());
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));

        //设置行间距
        mUsbDriver.write(PrintCmd.SetReadZKmode(3));

        mUsbDriver.write(PrintCmd.SetAlignment(0));
        m_sbData = new StringBuilder("税率10%");
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 1));
        mUsbDriver.write(PrintCmd.PrintNextHT());
        mUsbDriver.write(PrintCmd.PrintNextHT());
        mUsbDriver.write(PrintCmd.SetAlignment(2));
        m_sbData = new StringBuilder(oh.getPayPrice());
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));

        mUsbDriver.write(PrintCmd.SetAlignment(0));
        m_sbData = new StringBuilder("(内消費税");
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 1));
        mUsbDriver.write(PrintCmd.PrintNextHT());
        mUsbDriver.write(PrintCmd.PrintNextHT());
        mUsbDriver.write(PrintCmd.SetAlignment(2));
        m_sbData = new StringBuilder(oh.getTax()+")");
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));

        mUsbDriver.write(PrintCmd.SetAlignment(0));
        m_sbData = new StringBuilder("税率8%");
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 1));
        mUsbDriver.write(PrintCmd.PrintNextHT());
        mUsbDriver.write(PrintCmd.PrintNextHT());
        mUsbDriver.write(PrintCmd.SetAlignment(2));
        m_sbData = new StringBuilder("0");
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));

        mUsbDriver.write(PrintCmd.SetAlignment(0));
        m_sbData = new StringBuilder("(内消費税");
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 1));
        mUsbDriver.write(PrintCmd.PrintNextHT());
        mUsbDriver.write(PrintCmd.PrintNextHT());
        mUsbDriver.write(PrintCmd.SetAlignment(2));
        m_sbData = new StringBuilder("0)");
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));

        mUsbDriver.write(PrintCmd.PrintFeedline(1));
        m_sbData = new StringBuilder("--------------------------------");
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));
        mUsbDriver.write(PrintCmd.PrintFeedline(1));

        mUsbDriver.write(PrintCmd.SetAlignment(0));
        m_sbData = new StringBuilder("No."+oh.getOrderId());
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));

        mUsbDriver.write(PrintCmd.PrintFeedline(1));

        mUsbDriver.write(PrintCmd.SetAlignment(0));
        m_sbData = new StringBuilder("上記正に領収いたしました。");
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));


        mUsbDriver.write(PrintCmd.PrintFeedline(1));

        /*m_sbData = new StringBuilder("但し");
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));
        m_sbData = new StringBuilder("--------------------------------");
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));*/

        //mUsbDriver.write(PrintCmd.PrintFeedline(1));

        mUsbDriver.write(PrintCmd.SetClean());





        mUsbDriver.write(PrintCmd.PrintFeedline(1));
        m_sbData = new StringBuilder(oh.getSignValue());
        mUsbDriver.write(PrintCmd.PrintQrcode(m_sbData.toString(), 27, 4, 0));

        mUsbDriver.write(PrintCmd.PrintFeedline(2));

        mUsbDriver.write(PrintCmd.SetAlignment(0));
        m_sbData = new StringBuilder(oh.getShopName());
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));

        mUsbDriver.write(PrintCmd.SetAlignment(0));
        m_sbData = new StringBuilder(oh.getTelephone());
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));

        mUsbDriver.write(PrintCmd.SetAlignment(0));
        m_sbData = new StringBuilder(oh.getShopAddress());
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));


        mUsbDriver.write(PrintCmd.PrintFeedline(5));

        mUsbDriver.write(PrintCmd.PrintCutpaper(1));
    }

    public void execute_print(UsbDriver mUsbDriver,OrderMenuList oh,Drawable sed,int CutpaperSet){

        /*String imgUrl = "https://images.gutingjun.com/upload/sed.bmp";

        System.out.println("in execute_print");
        ExecutorService newCachedThreadPool = Executors.newCachedThreadPool();

        try{
            Future<byte[]> future = newCachedThreadPool.submit(new HttpCallable(imgUrl));
            byte[] result = future.get();
            mUsbDriver.write(result);
        }catch (Exception e){
            System.out.println("http Exception");
        }
*/
        //mUsbDriver.write(PrintCmd.SetClean());

        printbmp(mUsbDriver,sed);

        mUsbDriver.write(PrintCmd.SetReadZKmode(0));
        PrintFeedDot(30);
        StringBuilder m_sbData;

        mUsbDriver.write(PrintCmd.SetSizetext(1,1));
        mUsbDriver.write(PrintCmd.SetAlignment(1));


        mUsbDriver.write(PrintCmd.SetAlignment(0));
        PrintFeedDot(20);

        mUsbDriver.write(PrintCmd.PrintFeedline(2));

        List<CategoryVos> lineList = oh.getCategoryVos();
        for (CategoryVos line:lineList) {
            mUsbDriver.write(PrintCmd.SetClean());
            List<LineVos> lineVosList = line.getLineVos();
            for (LineVos lineVos:lineVosList){
                mUsbDriver.write(PrintCmd.SetClean());

                //mUsbDriver.write(PrintCmd.SetSizechar(1,1,0,0)); //放大
                mUsbDriver.write(PrintCmd.SetBold(1)); //加粗

                m_sbData = new StringBuilder(lineVos.getMenuNamePrintStr());
                mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));


                mUsbDriver.write(PrintCmd.SetClean());

                List<OptionVos> lineoptionlist = lineVos.getOptionVos();
                for (OptionVos lineoptionVos:lineoptionlist){

                    m_sbData = new StringBuilder(lineoptionVos.getOptionPrintStr());
                    mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));



                }
                mUsbDriver.write(PrintCmd.SetClean());
                mUsbDriver.write(PrintCmd.PrintFeedline(2));

            }

            mUsbDriver.write(PrintCmd.SetAlignment(1));
            m_sbData = new StringBuilder("-------------------------------");
            mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));

            mUsbDriver.write(PrintCmd.PrintFeedline(1));
            //mUsbDriver.write(PrintCmd.SetClean());
        }


        mUsbDriver.write(PrintCmd.PrintFeedline(1));

       /* m_sbData = new StringBuilder("-------------------------------");
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));*/

        mUsbDriver.write(PrintCmd.SetSizetext(1,1));
        m_sbData = new StringBuilder("合計：");
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 1));
        mUsbDriver.write(PrintCmd.PrintNextHT());
        m_sbData = new StringBuilder(oh.getPayPrice());
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));

        mUsbDriver.write(PrintCmd.SetClean());

        /*m_sbData = new StringBuilder("内消费税：");
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 1));
        mUsbDriver.write(PrintCmd.PrintNextHT());
        m_sbData = new StringBuilder(oh.getTax());
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));*/




        //m_sbData = new StringBuilder(oh.getSignValue());
        //mUsbDriver.write(PrintCmd.Print1Dbar(2,15,1,2,0,m_sbData.toString()));
        PrintFeedDot(20);


        mUsbDriver.write(PrintCmd.PrintFeedline(10));

        mUsbDriver.write(PrintCmd.PrintCutpaper(CutpaperSet));
    }

    private void printbmp(UsbDriver mUsbDriver,Drawable sed){

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


    //显示指定空格
    public String multipleSpaces(int n) {
        String output = "";

        for (int i = 0; i < n; i++)
            output += "-";

        return output;
    }


    }
