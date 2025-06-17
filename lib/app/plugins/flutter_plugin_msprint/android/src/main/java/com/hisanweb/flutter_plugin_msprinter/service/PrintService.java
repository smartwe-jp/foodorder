package com.hisanweb.flutter_plugin_msprinter.service;

import static com.hisanweb.flutter_plugin_msprinter.msprintsdk.PrintCmd.PrintDiskImagefile;
import static com.hisanweb.flutter_plugin_msprinter.msprintsdk.PrintCmd.PrintFeedDot;
import static com.hisanweb.flutter_plugin_msprinter.msprintsdk.UtilsTools.convertToBlackWhite;
import static com.hisanweb.flutter_plugin_msprinter.msprintsdk.UtilsTools.data;

import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
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

import com.hisanweb.flutter_plugin_msprinter.reserveInfo.ReserveList;

import android.util.Base64;

import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import static com.hisanweb.flutter_plugin_msprinter.msprintsdk.UtilsTools.data;
import static com.hisanweb.flutter_plugin_msprinter.msprintsdk.UtilsTools.hexStringToBytes;

import java.io.File;
import java.nio.file.Files;
import java.io.IOException;
import java.nio.file.Path;


public class PrintService  {

    public void execute_printRreceipt(UsbDriver mUsbDriver,OrderMenuList oh,Drawable sed){
        mUsbDriver.write(PrintCmd.SetAlignment(1));
        printbmp(mUsbDriver,sed);

        PrintFeedDot(2);
        StringBuilder m_sbData;

        mUsbDriver.write(PrintCmd.SetAlignment(0));

        m_sbData = new StringBuilder(oh.getTelephone());
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));

        m_sbData = new StringBuilder(oh.getShopAddress());
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));


        mUsbDriver.write(PrintCmd.SetSizetext(1,1));
        mUsbDriver.write(PrintCmd.SetAlignment(1));
        m_sbData = new StringBuilder("領 収 書");
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));
        mUsbDriver.write(PrintCmd.SetClean());

        mUsbDriver.write(PrintCmd.SetAlignment(2));
        mUsbDriver.write(PrintCmd.SetBold(1)); //加粗
        //￥
        //mUsbDriver.write(PrintCmd.PrintString(" ", 0));
        mUsbDriver.write(PrintCmd.JNAStringToByte("9D",1));

        m_sbData = new StringBuilder(oh.getPayPrice());
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 1));

        mUsbDriver.write(PrintCmd.PrintString("", 0));
        m_sbData = new StringBuilder("--------------------------------");
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));

        mUsbDriver.write(PrintCmd.SetClean());


        byte[] bByte = new byte[1];
        bByte[0] = 28;
        //bByte[1] = 10;
        mUsbDriver.write(PrintCmd.SetHTseat(bByte, 1));

        mUsbDriver.write(PrintCmd.SetAlignment(0));
        m_sbData = new StringBuilder(oh.getLine1());
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 1));
        mUsbDriver.write(PrintCmd.JNAStringToByte("9D",1));
        m_sbData = new StringBuilder(oh.getExcludingTaxStr());
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));
        //设置行间距

        m_sbData = new StringBuilder(oh.getLine2());
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 1));
        mUsbDriver.write(PrintCmd.JNAStringToByte("9D",1));
        m_sbData = new StringBuilder(oh.getTaxStr());
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));
        //设置行间距

        m_sbData = new StringBuilder(oh.getLine3());
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 1));
        mUsbDriver.write(PrintCmd.JNAStringToByte("9D",1));
        m_sbData = new StringBuilder(oh.getPriceStr());
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));
        //设置行间距

        m_sbData = new StringBuilder(oh.getLine4());
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 1));
        mUsbDriver.write(PrintCmd.JNAStringToByte("9D",1));
        m_sbData = new StringBuilder(oh.getLine4Rate());
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));
        //设置行间距

        m_sbData = new StringBuilder(oh.getLine5());
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 1));
        mUsbDriver.write(PrintCmd.JNAStringToByte("9D",1));
        m_sbData = new StringBuilder(oh.getTaxRate0Str());
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));
        //设置行间距
        m_sbData = new StringBuilder(oh.getLine6());
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 1));
        mUsbDriver.write(PrintCmd.JNAStringToByte("9D",1));
        m_sbData = new StringBuilder(oh.getTaxRate1Str());
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));

        //mUsbDriver.write(PrintCmd.PrintFeedline(1));
        m_sbData = new StringBuilder("--------------------------------");
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));




        m_sbData = new StringBuilder("お明細は上記のとおりです。");//上記正に領収いたしました。
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));


        //m_sbData = new StringBuilder(oh.getSignValue());
        //mUsbDriver.write(PrintCmd.PrintQrcode(m_sbData.toString(), 27, 4, 0));

        //mUsbDriver.write(PrintCmd.PrintFeedline(1));

        //mUsbDriver.write(PrintCmd.SetAlignment(0));
        //m_sbData = new StringBuilder(oh.getShopName());
        //mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));

        m_sbData = new StringBuilder(oh.getOrderDate());
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));


        if(oh.getPayMethod() != null && oh.getPayMethod().length() > 0){
            mUsbDriver.write(PrintCmd.PrintFeedline(1));
            mUsbDriver.write(PrintCmd.SetAlignment(1));
            mUsbDriver.write(PrintCmd.SetSizechar(0,0,1,0));
            m_sbData = new StringBuilder(oh.getPayMethod());
            mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));

            mUsbDriver.write(PrintCmd.SetAlignment(0));
            mUsbDriver.write(PrintCmd.SetSizechar(0,0,0,0));
            m_sbData = new StringBuilder(oh.getMemberNo());
            mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));
            m_sbData = new StringBuilder(oh.getPayDate());
            mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));
        }



        PrintFeedDot(10);

        mUsbDriver.write(PrintCmd.PrintFeedline(5));
        mUsbDriver.write(PrintCmd.PrintCutpaper(0));

    }

    public void execute_print(UsbDriver mUsbDriver,OrderMenuList oh,Drawable sed,int CutpaperSet){
        StringBuilder m_sbData;

        /*mUsbDriver.write(PrintCmd.SetUnderline(1));
        mUsbDriver.write(PrintCmd.SetBold(1));
        m_sbData = new StringBuilder(oh.getLine7());
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));
        mUsbDriver.write(PrintCmd.SetClean());

        m_sbData = new StringBuilder(oh.getOrderDate()+"   店舗控え");
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));*/
        mUsbDriver.write(PrintCmd.SetSizetext(1,1));
        mUsbDriver.write(PrintCmd.SetAlignment(0));
        m_sbData = new StringBuilder(oh.getLine7()+"    ");
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 1));
        //m_sbData = new StringBuilder("001");
        mUsbDriver.write(PrintCmd.SetAlignment(1));
        m_sbData = new StringBuilder(oh.getSerialNumber());
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));
        mUsbDriver.write(PrintCmd.SetClean());

        m_sbData = new StringBuilder("--------------------------------");
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));


        List<CategoryVos> lineList = oh.getCategoryVos();
        int categoryNum = lineList.size();
        int categoryshowNum = 0;
        for (CategoryVos line:lineList) {
            int linNum = 0;
            List<LineVos> lineVosList = line.getLineVos();
            int linVoNum = lineVosList.size();
            for (LineVos lineVos:lineVosList){

                m_sbData = new StringBuilder(lineVos.getMenuNamePrintStr());
                mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));


                List<OptionVos> lineoptionlist = lineVos.getOptionVos();
                for (OptionVos lineoptionVos:lineoptionlist){
                    m_sbData = new StringBuilder(lineoptionVos.getOptionPrintStr());
                    mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));
                }

                linNum++;

                if(lineoptionlist.size() >0 && linNum != linVoNum){
                    m_sbData = new StringBuilder("--------------------------------");
                    mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));
                }


            }

            categoryshowNum++;
            if(categoryNum != categoryshowNum) {
                m_sbData = new StringBuilder("--------------------------------");
                mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));
            }

        }

        //m_sbData = new StringBuilder("No."+oh.getOrderId());
        //mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));


        PrintFeedDot(20);


        mUsbDriver.write(PrintCmd.PrintFeedline(6));

        mUsbDriver.write(PrintCmd.PrintCutpaper(CutpaperSet));
    }

    public void execute_printRreceipt_eighty(UsbDriver mUsbDriver,OrderMenuList oh,Drawable sed){
        mUsbDriver.write(PrintCmd.SetAlignment(1));
        printbmp(mUsbDriver,sed);
        PrintFeedDot(5);
        StringBuilder m_sbData;
        mUsbDriver.write(PrintCmd.SetAlignment(0));

        m_sbData = new StringBuilder(oh.getTelephone());
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));

        m_sbData = new StringBuilder(oh.getShopAddress());
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));

        mUsbDriver.write(PrintCmd.SetSizetext(1,1));
        mUsbDriver.write(PrintCmd.SetAlignment(1));
        m_sbData = new StringBuilder("領 収 書");
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));
        mUsbDriver.write(PrintCmd.SetAlignment(0));
        mUsbDriver.write(PrintCmd.SetClean());

        mUsbDriver.write(PrintCmd.SetAlignment(2));
        mUsbDriver.write(PrintCmd.SetBold(1)); //加粗
        //￥

        mUsbDriver.write(PrintCmd.JNAStringToByte("9D",1));

        m_sbData = new StringBuilder(oh.getPayPrice());
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 1));

        mUsbDriver.write(PrintCmd.PrintString("", 0));
        m_sbData = new StringBuilder("------------------------------------------------");
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));

        mUsbDriver.write(PrintCmd.SetClean());


        byte[] bByte = new byte[1];
        bByte[0] = 28;
        //bByte[1] = 10;
        mUsbDriver.write(PrintCmd.SetHTseat(bByte, 1));

        mUsbDriver.write(PrintCmd.SetAlignment(0));
        m_sbData = new StringBuilder(oh.getLine1());
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 1));
        mUsbDriver.write(PrintCmd.JNAStringToByte("9D",1));
        m_sbData = new StringBuilder(oh.getExcludingTaxStr());
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));
        //设置行间距

        m_sbData = new StringBuilder(oh.getLine2());
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 1));
        mUsbDriver.write(PrintCmd.JNAStringToByte("9D",1));
        m_sbData = new StringBuilder(oh.getTaxStr());
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));
        //设置行间距

        m_sbData = new StringBuilder(oh.getLine3());
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 1));
        mUsbDriver.write(PrintCmd.JNAStringToByte("9D",1));
        m_sbData = new StringBuilder(oh.getPriceStr());
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));
        //设置行间距

        m_sbData = new StringBuilder(oh.getLine4());
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 1));
        mUsbDriver.write(PrintCmd.JNAStringToByte("9D",1));
        m_sbData = new StringBuilder(oh.getLine4Rate());
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));
        //设置行间距

        m_sbData = new StringBuilder(oh.getLine5());
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 1));
        mUsbDriver.write(PrintCmd.JNAStringToByte("9D",1));
        m_sbData = new StringBuilder(oh.getTaxRate0Str());
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));
        //设置行间距
        m_sbData = new StringBuilder(oh.getLine6());
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 1));
        mUsbDriver.write(PrintCmd.JNAStringToByte("9D",1));
        m_sbData = new StringBuilder(oh.getTaxRate1Str());
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));



        m_sbData = new StringBuilder("------------------------------------------------");
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));




        mUsbDriver.write(PrintCmd.SetAlignment(0));
        m_sbData = new StringBuilder("お明細は上記のとおりです。");//上記正に領収いたしました。
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));




        /*m_sbData = new StringBuilder(oh.getSignValue());
        mUsbDriver.write(PrintCmd.PrintQrcode(m_sbData.toString(), 27, 4, 0));

        mUsbDriver.write(PrintCmd.PrintFeedline(1));

        mUsbDriver.write(PrintCmd.SetAlignment(0));
        m_sbData = new StringBuilder(oh.getShopName());
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));*/

        m_sbData = new StringBuilder(oh.getOrderDate());
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));

        if(oh.getPayMethod() != null && oh.getPayMethod().length() > 0){
            mUsbDriver.write(PrintCmd.PrintFeedline(1));
            mUsbDriver.write(PrintCmd.SetAlignment(1));
            mUsbDriver.write(PrintCmd.SetSizechar(0,0,1,0));
            m_sbData = new StringBuilder(oh.getPayMethod());
            mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));

            mUsbDriver.write(PrintCmd.SetAlignment(0));
            mUsbDriver.write(PrintCmd.SetSizechar(0,0,0,0));
            m_sbData = new StringBuilder(oh.getMemberNo());
            mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));
            m_sbData = new StringBuilder(oh.getPayDate());
            mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));
        }


        PrintFeedDot(10);


        mUsbDriver.write(PrintCmd.PrintFeedline(5));

        mUsbDriver.write(PrintCmd.PrintCutpaper(0));



    }

    public void execute_print_eighty(UsbDriver mUsbDriver,OrderMenuList oh,Drawable sed,int CutpaperSet){


        StringBuilder m_sbData;


        /*mUsbDriver.write(PrintCmd.SetBold(1));
        mUsbDriver.write(PrintCmd.SetUnderline(1));
        m_sbData = new StringBuilder(oh.getLine7());
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));
        mUsbDriver.write(PrintCmd.SetClean());

        m_sbData = new StringBuilder(oh.getOrderDate()+"              店舗控え");
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));

        m_sbData = new StringBuilder("------------------------------------------------");
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));*/
        mUsbDriver.write(PrintCmd.SetSizetext(1,1));
        mUsbDriver.write(PrintCmd.SetAlignment(0));
        //m_sbData = new StringBuilder("001");
        m_sbData = new StringBuilder(oh.getLine7()+"    ");
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 1));
        mUsbDriver.write(PrintCmd.SetAlignment(1));
        m_sbData = new StringBuilder(oh.getSerialNumber());
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));
        mUsbDriver.write(PrintCmd.SetClean());


        List<CategoryVos> lineList = oh.getCategoryVos();
        int categoryNum = lineList.size();
        int categoryshowNum = 0;
        for (CategoryVos line:lineList) {
            mUsbDriver.write(PrintCmd.SetSizetext(1,1));
            int linNum = 0;

            List<LineVos> lineVosList = line.getLineVos();
            int linVoNum = lineVosList.size();
            for (LineVos lineVos:lineVosList){
                mUsbDriver.write(PrintCmd.SetSizetext(1,1));
                m_sbData = new StringBuilder(lineVos.getMenuNamePrintStr());
                mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));


                List<OptionVos> lineoptionlist = lineVos.getOptionVos();
                for (OptionVos lineoptionVos:lineoptionlist){

                    m_sbData = new StringBuilder(lineoptionVos.getOptionPrintStr());
                    mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));
                }


                linNum++;

                if(lineoptionlist.size() >0 && linNum != linVoNum){
                    mUsbDriver.write(PrintCmd.SetSizetext(0,0));
                    m_sbData = new StringBuilder("------------------------------------------------");
                    mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));
                }

            }

            categoryshowNum++;
            if(categoryNum != categoryshowNum) {
                mUsbDriver.write(PrintCmd.SetSizetext(0, 0));
                m_sbData = new StringBuilder("------------------------------------------------");
                mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));
            }

        }
        //mUsbDriver.write(PrintCmd.SetClean());

        /*mUsbDriver.write(PrintCmd.SetAlignment(0));
        m_sbData = new StringBuilder("No."+oh.getOrderId());
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));*/

        PrintFeedDot(20);

        mUsbDriver.write(PrintCmd.PrintFeedline(6));

        mUsbDriver.write(PrintCmd.PrintCutpaper(CutpaperSet));
    }


    public void execute_reserve_printRreceipt(UsbDriver mUsbDriver,ReserveList oh,Drawable sed){
        mUsbDriver.write(PrintCmd.SetAlignment(1));
        printbmp(mUsbDriver,sed);

        PrintFeedDot(10);
        StringBuilder m_sbData;
        mUsbDriver.write(PrintCmd.SetAlignment(0));
        mUsbDriver.write(PrintCmd.PrintFeedline(1));
        m_sbData = new StringBuilder(oh.getReserveTime());
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));

        mUsbDriver.write(PrintCmd.PrintFeedline(2));

        mUsbDriver.write(PrintCmd.SetAlignment(1));
        mUsbDriver.write(PrintCmd.SetBold(1));
        mUsbDriver.write(PrintCmd.SetSizetext(3,3));
        m_sbData = new StringBuilder(oh.getTableType()+oh.getReserveNo());
        mUsbDriver.write(PrintCmd.PrintString(m_sbData.toString(), 0));
        mUsbDriver.write(PrintCmd.SetClean());


        PrintFeedDot(20);

        mUsbDriver.write(PrintCmd.PrintFeedline(5));
        mUsbDriver.write(PrintCmd.PrintCutpaper(0));

    }

    public void execute_reserve_printImg(UsbDriver mUsbDriver,String content,String cutMode,String isTop){
        int width,heigh;

        byte[] bytes = Base64.decode(content, Base64.DEFAULT);
        Bitmap bitmap = BitmapFactory.decodeByteArray(bytes, 0, bytes.length);

        width = bitmap.getWidth();
        heigh = bitmap.getHeight();
        int iDataLen = width * heigh;
        int[] pixels = new int[iDataLen];
        bitmap.getPixels(pixels, 0, width, 0, 0, width, heigh);
        int[] data1 = pixels;
        mUsbDriver.write(PrintDiskImagefile(data1, width, heigh));


        /*byte[] bSendData;
        String strdata = "1D 76 30 00 30 00 5D 00 00 00 00 00 00 00 00 00 00 00 03 FF C0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 3F FF F8 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 07 FF FF FF 80 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 07 FF FF FF 80 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 07 FF FF FF 80 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 1F FF FF FF C0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 FF FF FF FF E0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 03 F0 00 0F FF F0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 06 00 00 03 FF FE 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 06 00 00 03 FF FE 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 08 00 00 00 FF FF 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 08 00 00 00 FF FF 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 70 00 00 00 3F FF 80 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 01 00 00 00 00 1F FF 80 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 0F FF 80 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 07 FF C0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 07 FF C0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 07 FF C0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 07 FF C0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 FF F0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 7F FF FF 80 00 01 FE 00 00 00 00 3F C0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 7F FF FF 80 00 01 FE 00 00 00 00 3F C0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 7F FF FF 80 00 03 FE 00 00 00 00 3F C0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 7F FF FF 80 00 03 FE 00 00 00 00 7F C0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 7F FF FF 80 00 03 FE 00 00 00 00 7F C0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 7F FF FF 80 00 03 FC 00 00 00 00 7F C0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 FF C0 00 00 00 00 00 00 00 00 00 7F 80 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 FF C0 00 00 00 00 00 00 00 00 00 7F 80 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 FF C0 00 00 00 00 00 00 00 00 00 7F 80 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 FF C0 00 00 00 0F FC 00 FF F8 0F FF FC 07 FF F0 0F F0 7F C0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 FF C0 00 00 00 0F FC 00 FF F8 0F FF FC 07 FF F0 0F F0 7F C0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 FF 00 00 00 00 0F FC 07 FF FF 0F FF FC 3F FF F8 0F F3 FF E0 00 00 00 00 00 00 00 00 00 00 00 00 C0 00 00 30 C0 00 00 00 00 00 00 18 00 00 00 00 FF 00 00 00 00 0F F8 1F FF FF 1F FF FC FF FF FC 0F FF FF F0 00 00 00 30 00 30 00 00 00 00 00 00 E0 00 00 30 C0 00 00 33 06 00 00 1C 00 00 00 03 FF FF FE 03 C0 0F F8 1F F3 FF C0 FF 81 FF 8F FC 1F FF FF F0 00 00 00 30 07 F8 00 00 00 00 00 00 E0 00 00 71 C0 00 06 3B 1F 00 00 38 00 00 00 03 FF FF FE 03 C0 0F F8 FF C0 7F C0 FF 01 FF 03 FE 1F F0 3F F0 00 00 00 1F FC 30 00 01 80 00 00 60 E0 00 00 71 80 00 07 F3 F6 00 00 30 60 00 00 03 FF FF FE 03 C0 0F F8 FF C0 7F C0 FF 01 FF 03 FE 1F F0 3F F0 00 00 00 1C 30 30 00 01 80 00 00 30 C0 00 00 E1 80 C0 06 33 06 00 00 67 F0 00 00 03 FF FF FE 03 C0 0F F8 FF C0 7F C0 FF 01 FF 03 FE 1F F0 3F F0 00 00 00 18 30 30 00 00 C0 00 00 1C C0 00 00 C3 1F C0 06 33 06 00 00 FC E0 00 00 03 FF FF F0 0F C0 3F F9 FF C0 7F C0 FF 03 FC 03 FE 1F E0 3F F0 00 00 00 18 30 30 00 00 E0 00 00 1C C0 00 01 C7 F1 80 06 33 0C 00 01 C1 C0 00 00 03 FF FF F0 0F C0 3F F9 FF C1 FF C7 FF 03 FC 03 FE 1F E0 3F E0 00 00 00 18 30 30 00 00 60 00 00 0C C0 00 03 C6 33 00 06 33 6C 00 03 F3 80 00 00 03 FF 00 00 00 00 3F F1 FF FF FF C7 FF 0F FC 03 FE 1F E0 7F E0 00 00 00 18 37 B0 00 00 71 80 00 01 C0 00 07 CC 33 00 06 F3 3C 00 07 1F 00 00 00 0F FE 00 00 00 00 3F F1 FF FF FF C7 FF 0F FC 03 FC 1F E0 7F E0 00 00 00 1B FE 30 00 00 70 C0 00 01 80 C0 06 DB 30 00 07 F3 1C 00 0E 0E 00 00 00 0F FE 00 00 00 00 3F F3 FF 00 00 07 FE 0F F8 03 FC FF E0 7F E0 00 00 00 18 30 30 00 C0 00 60 00 01 9F C0 0C C3 BC 00 06 33 00 00 18 1F 80 00 00 0F FE 00 00 00 00 3F F3 FF 00 00 07 FE 0F F8 03 FC FF E0 7F E0 00 00 00 18 30 30 00 C0 00 38 00 3F F1 C0 18 C7 37 00 06 33 0F 00 00 39 C0 00 00 0F FE 00 00 00 00 3F F3 FF 00 00 07 FE 0F F8 03 FC FF E0 7F E0 00 00 00 18 30 30 00 D8 00 3C 01 F3 81 80 00 CE 33 80 06 33 FE 00 00 F8 F0 00 00 0F FE 00 00 00 00 7F F3 FF 00 00 07 FE 0F F8 03 FC FF C0 7F C0 00 00 00 18 31 B0 01 D8 00 1C 00 03 01 80 00 D8 31 C0 06 F3 06 00 01 DC 3C 00 00 0F FE 00 00 00 00 7F F3 FF 01 FF 0F FE 0F F8 0F F8 FF C0 7F C0 00 00 00 18 7F B0 01 D8 00 0C 00 03 01 80 00 F1 B0 C0 07 B3 C6 00 07 1C 1F 00 00 0F F8 00 00 00 00 7F 83 FF 03 FC 0F FE 0F F8 3F F8 FF C0 7F C0 00 00 00 1F F0 30 01 9C 00 00 00 07 01 80 01 C0 F0 00 0C 33 6C 00 1C 18 7F F0 00 1F FF FF E0 00 00 7F 81 FF DF FC 0F FF 0F FF 7F F1 FF C1 FF C0 00 00 00 30 30 30 01 8C 00 00 00 06 E1 80 00 C0 70 00 0C 33 6C 00 70 1F F3 00 00 1F FF FF E0 00 00 7F 81 FF FF F8 0F FF 83 FF FF 81 FF C1 FF C0 00 00 00 30 30 30 03 8C 03 00 00 06 73 80 00 06 3C 00 0C 33 3C 00 C7 F8 60 00 00 1F FF FF E0 00 00 7F 81 FF FF F8 0F FF 83 FF FF 81 FF C1 FF C0 00 00 00 30 30 30 07 86 03 00 00 0C 33 00 03 03 87 00 0C 33 18 00 00 38 60 00 00 1F FF FF E0 00 00 7F 81 FF FF F8 0F FF 83 FF FF 81 FF C1 FF C0 00 00 00 30 30 30 03 06 03 00 00 1C 33 00 03 61 C3 C0 0C 33 18 00 00 30 60 00 00 1F FF FF E0 00 00 FF 80 FF FF F0 0F FF 01 FF FF 01 FF 01 FF 00 00 00 00 60 30 30 03 03 01 80 00 18 03 00 03 60 C0 E0 18 33 3C 00 00 70 60 00 00 1F FF FF E0 00 00 FF 80 0F FE 00 07 FF 00 FF FC 01 FF 01 FF 00 00 00 00 60 30 30 00 03 81 80 00 30 03 00 07 30 00 60 18 33 7E 00 00 60 E0 00 00 00 00 00 00 00 00 FF 00 00 00 00 00 00 00 00 00 01 00 00 00 00 00 00 00 E0 30 30 00 01 E1 80 00 71 87 00 07 18 00 00 18 33 67 00 00 E0 C0 00 00 00 00 00 00 00 00 FF 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 C0 31 B0 00 00 79 C0 00 E0 C6 00 0E 0C 0C 00 31 B3 C3 C0 01 D8 C0 00 00 00 00 00 00 00 00 FF 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 01 80 30 F0 00 00 0F C0 01 C0 76 00 0E 07 0C 00 30 F3 C3 F0 03 8E C0 00 00 00 00 00 00 00 03 FF 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 03 00 30 70 00 00 00 00 03 80 3E 00 00 01 CE 00 60 73 80 00 06 07 C0 00 00 00 00 00 00 00 03 FF 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 30 00 00 00 00 06 00 1C 00 00 00 7E 00 00 33 00 00 0C 03 80 00 00 00 00 00 00 00 1F FE 00 00 00 00 1F F0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 1C 00 0C 00 00 00 00 00 00 00 00 00 38 01 80 00 00 00 00 00 00 00 1F FE 00 00 00 00 3F E0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 1F FC 00 00 00 00 FF E0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 1F FC 00 00 00 00 FF E0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 FF C0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 03 FF 80 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 03 FF 80 00 00 00 01 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 07 FF 80 00 21 E0 01 83 00 00 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 02 00 00 00 00 00 0F FF 00 00 3E 40 01 02 00 00 1E 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 02 00 00 00 00 00 0F FF 00 00 27 80 01 02 60 21 E4 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 3F F8 00 00 78 80 02 3F 80 10 48 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 01 00 00 00 00 00 7F F0 00 00 40 80 02 44 00 10 30 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 01 C0 00 00 00 01 FF E0 00 00 4F 80 1F 87 80 02 3E 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 01 C0 00 00 00 01 FF E0 00 00 F8 00 24 79 00 03 C2 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 C0 00 00 00 03 FF C0 00 00 A0 00 04 09 E0 12 44 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 E0 00 00 00 0F FF 00 00 00 47 E0 06 FF 03 E3 F4 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 E0 00 00 00 0F FF 00 00 00 FA 40 19 12 00 44 88 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 38 00 00 00 3F FC 00 00 03 24 80 68 1E 00 44 88 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 1F 00 00 03 FF F8 00 00 04 48 81 8B F0 00 47 E8 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 07 80 00 0F FF F0 00 00 18 91 00 11 20 00 49 10 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 07 80 00 0F FF F0 00 00 23 22 00 11 3C 00 89 10 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 03 FC 03 FF FF 80 00 00 04 42 00 12 20 00 9A A0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 03 FC 03 FF FF 80 00 00 18 84 00 23 C0 0F D2 60 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 FF FF FF FC 00 00 00 23 28 01 24 60 00 38 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 7F FF FF F0 00 00 00 0C 30 00 C8 18 00 07 8C 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 0F FF FF 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 FF E0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 FF E0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 FF E0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ";
        bSendData = hexStringToBytes(strdata);
        mUsbDriver.write(bSendData);*/
        PrintFeedDot(20);
        int cutPaper = Integer.parseInt(cutMode);

        mUsbDriver.write(PrintCmd.PrintFeedline(5));
        mUsbDriver.write(PrintCmd.PrintCutpaper(cutPaper));

    }

    public void execute_reserve_printImgNew(UsbDriver mUsbDriver,String content,String cutMode,String isTop, String topImage){
        int width,heigh;

        if(isTop.equals("1")){
            mUsbDriver.write(PrintCmd.SetAlignment(1));
            //printbmp(mUsbDriver,sed);
            //String imgUrl = "https://images.gutingjun.com/upload/sed.bmp";
//            ExecutorService newCachedThreadPool = Executors.newCachedThreadPool();
//            try{
//                Future<byte[]> future = newCachedThreadPool.submit(new HttpCallable(topImage));
//                byte[] result = future.get();
//                mUsbDriver.write(result);
//            }catch (Exception e){
//                System.out.println("http Exception");
//            }
//            if (topImage != null) {
//                System.out.println("topImage:" + topImage);
//                byte[] bytes = Base64.decode(topImage, Base64.DEFAULT);
//                Bitmap bitmap = BitmapFactory.decodeByteArray(bytes, 0, bytes.length);
//
//                width = bitmap.getWidth();
//                heigh = bitmap.getHeight();
//                System.out.println("topImageSize:" + width + ":" + heigh);
//                int iDataLen = width * heigh;
//                int[] pixels = new int[iDataLen];
//                bitmap.getPixels(pixels, 0, width, 0, 0, width, heigh);
//                int[] data1 = pixels;
//                mUsbDriver.write(PrintDiskImagefile(data1, width, heigh));

//                File file = new File(topImage);
//                if (file.exists()) {
//                    try {
//                        byte[] imageData = Files.readAllBytes(file.toPath());
//                        // 处理图像数据
//                        //processImage(imageData);
//                        Bitmap bitmap = BitmapFactory.decodeByteArray(imageData, 0, imageData.length);
//
//                        width = bitmap.getWidth();
//                        heigh = bitmap.getHeight();
//                        int iDataLen = width * heigh;
//                        int[] pixels = new int[iDataLen];
//                        bitmap.getPixels(pixels, 0, width, 0, 0, width, heigh);
//                        int[] data1 = pixels;
//                        mUsbDriver.write(PrintDiskImagefile(data1, width, heigh));
//                        //mUsbDriver.write(imageData);
//                        //result.success("Image processed successfully");
//                    } catch (IOException e) {
//                        //result.error("IO_ERROR", "Error reading file", e.getMessage());
//                    }
//                } else {
//                    //result.error("FILE_NOT_FOUND", "Image file not found", null);
//                }

//            }
        }

        byte[] bytes = Base64.decode(content, Base64.DEFAULT);
        Bitmap bitmap = BitmapFactory.decodeByteArray(bytes, 0, bytes.length);

        width = bitmap.getWidth();
        heigh = bitmap.getHeight();
        int iDataLen = width * heigh;
        int[] pixels = new int[iDataLen];
        bitmap.getPixels(pixels, 0, width, 0, 0, width, heigh);
        int[] data1 = pixels;
        mUsbDriver.write(PrintDiskImagefile(data1, width, heigh));


        /*byte[] bSendData;
        String strdata = "1D 76 30 00 30 00 5D 00 00 00 00 00 00 00 00 00 00 00 03 FF C0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 3F FF F8 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 07 FF FF FF 80 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 07 FF FF FF 80 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 07 FF FF FF 80 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 1F FF FF FF C0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 FF FF FF FF E0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 03 F0 00 0F FF F0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 06 00 00 03 FF FE 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 06 00 00 03 FF FE 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 08 00 00 00 FF FF 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 08 00 00 00 FF FF 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 70 00 00 00 3F FF 80 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 01 00 00 00 00 1F FF 80 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 0F FF 80 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 07 FF C0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 07 FF C0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 07 FF C0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 07 FF C0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 FF F0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 7F FF FF 80 00 01 FE 00 00 00 00 3F C0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 7F FF FF 80 00 01 FE 00 00 00 00 3F C0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 7F FF FF 80 00 03 FE 00 00 00 00 3F C0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 7F FF FF 80 00 03 FE 00 00 00 00 7F C0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 7F FF FF 80 00 03 FE 00 00 00 00 7F C0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 7F FF FF 80 00 03 FC 00 00 00 00 7F C0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 FF C0 00 00 00 00 00 00 00 00 00 7F 80 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 FF C0 00 00 00 00 00 00 00 00 00 7F 80 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 FF C0 00 00 00 00 00 00 00 00 00 7F 80 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 FF C0 00 00 00 0F FC 00 FF F8 0F FF FC 07 FF F0 0F F0 7F C0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 FF C0 00 00 00 0F FC 00 FF F8 0F FF FC 07 FF F0 0F F0 7F C0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 FF 00 00 00 00 0F FC 07 FF FF 0F FF FC 3F FF F8 0F F3 FF E0 00 00 00 00 00 00 00 00 00 00 00 00 C0 00 00 30 C0 00 00 00 00 00 00 18 00 00 00 00 FF 00 00 00 00 0F F8 1F FF FF 1F FF FC FF FF FC 0F FF FF F0 00 00 00 30 00 30 00 00 00 00 00 00 E0 00 00 30 C0 00 00 33 06 00 00 1C 00 00 00 03 FF FF FE 03 C0 0F F8 1F F3 FF C0 FF 81 FF 8F FC 1F FF FF F0 00 00 00 30 07 F8 00 00 00 00 00 00 E0 00 00 71 C0 00 06 3B 1F 00 00 38 00 00 00 03 FF FF FE 03 C0 0F F8 FF C0 7F C0 FF 01 FF 03 FE 1F F0 3F F0 00 00 00 1F FC 30 00 01 80 00 00 60 E0 00 00 71 80 00 07 F3 F6 00 00 30 60 00 00 03 FF FF FE 03 C0 0F F8 FF C0 7F C0 FF 01 FF 03 FE 1F F0 3F F0 00 00 00 1C 30 30 00 01 80 00 00 30 C0 00 00 E1 80 C0 06 33 06 00 00 67 F0 00 00 03 FF FF FE 03 C0 0F F8 FF C0 7F C0 FF 01 FF 03 FE 1F F0 3F F0 00 00 00 18 30 30 00 00 C0 00 00 1C C0 00 00 C3 1F C0 06 33 06 00 00 FC E0 00 00 03 FF FF F0 0F C0 3F F9 FF C0 7F C0 FF 03 FC 03 FE 1F E0 3F F0 00 00 00 18 30 30 00 00 E0 00 00 1C C0 00 01 C7 F1 80 06 33 0C 00 01 C1 C0 00 00 03 FF FF F0 0F C0 3F F9 FF C1 FF C7 FF 03 FC 03 FE 1F E0 3F E0 00 00 00 18 30 30 00 00 60 00 00 0C C0 00 03 C6 33 00 06 33 6C 00 03 F3 80 00 00 03 FF 00 00 00 00 3F F1 FF FF FF C7 FF 0F FC 03 FE 1F E0 7F E0 00 00 00 18 37 B0 00 00 71 80 00 01 C0 00 07 CC 33 00 06 F3 3C 00 07 1F 00 00 00 0F FE 00 00 00 00 3F F1 FF FF FF C7 FF 0F FC 03 FC 1F E0 7F E0 00 00 00 1B FE 30 00 00 70 C0 00 01 80 C0 06 DB 30 00 07 F3 1C 00 0E 0E 00 00 00 0F FE 00 00 00 00 3F F3 FF 00 00 07 FE 0F F8 03 FC FF E0 7F E0 00 00 00 18 30 30 00 C0 00 60 00 01 9F C0 0C C3 BC 00 06 33 00 00 18 1F 80 00 00 0F FE 00 00 00 00 3F F3 FF 00 00 07 FE 0F F8 03 FC FF E0 7F E0 00 00 00 18 30 30 00 C0 00 38 00 3F F1 C0 18 C7 37 00 06 33 0F 00 00 39 C0 00 00 0F FE 00 00 00 00 3F F3 FF 00 00 07 FE 0F F8 03 FC FF E0 7F E0 00 00 00 18 30 30 00 D8 00 3C 01 F3 81 80 00 CE 33 80 06 33 FE 00 00 F8 F0 00 00 0F FE 00 00 00 00 7F F3 FF 00 00 07 FE 0F F8 03 FC FF C0 7F C0 00 00 00 18 31 B0 01 D8 00 1C 00 03 01 80 00 D8 31 C0 06 F3 06 00 01 DC 3C 00 00 0F FE 00 00 00 00 7F F3 FF 01 FF 0F FE 0F F8 0F F8 FF C0 7F C0 00 00 00 18 7F B0 01 D8 00 0C 00 03 01 80 00 F1 B0 C0 07 B3 C6 00 07 1C 1F 00 00 0F F8 00 00 00 00 7F 83 FF 03 FC 0F FE 0F F8 3F F8 FF C0 7F C0 00 00 00 1F F0 30 01 9C 00 00 00 07 01 80 01 C0 F0 00 0C 33 6C 00 1C 18 7F F0 00 1F FF FF E0 00 00 7F 81 FF DF FC 0F FF 0F FF 7F F1 FF C1 FF C0 00 00 00 30 30 30 01 8C 00 00 00 06 E1 80 00 C0 70 00 0C 33 6C 00 70 1F F3 00 00 1F FF FF E0 00 00 7F 81 FF FF F8 0F FF 83 FF FF 81 FF C1 FF C0 00 00 00 30 30 30 03 8C 03 00 00 06 73 80 00 06 3C 00 0C 33 3C 00 C7 F8 60 00 00 1F FF FF E0 00 00 7F 81 FF FF F8 0F FF 83 FF FF 81 FF C1 FF C0 00 00 00 30 30 30 07 86 03 00 00 0C 33 00 03 03 87 00 0C 33 18 00 00 38 60 00 00 1F FF FF E0 00 00 7F 81 FF FF F8 0F FF 83 FF FF 81 FF C1 FF C0 00 00 00 30 30 30 03 06 03 00 00 1C 33 00 03 61 C3 C0 0C 33 18 00 00 30 60 00 00 1F FF FF E0 00 00 FF 80 FF FF F0 0F FF 01 FF FF 01 FF 01 FF 00 00 00 00 60 30 30 03 03 01 80 00 18 03 00 03 60 C0 E0 18 33 3C 00 00 70 60 00 00 1F FF FF E0 00 00 FF 80 0F FE 00 07 FF 00 FF FC 01 FF 01 FF 00 00 00 00 60 30 30 00 03 81 80 00 30 03 00 07 30 00 60 18 33 7E 00 00 60 E0 00 00 00 00 00 00 00 00 FF 00 00 00 00 00 00 00 00 00 01 00 00 00 00 00 00 00 E0 30 30 00 01 E1 80 00 71 87 00 07 18 00 00 18 33 67 00 00 E0 C0 00 00 00 00 00 00 00 00 FF 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 C0 31 B0 00 00 79 C0 00 E0 C6 00 0E 0C 0C 00 31 B3 C3 C0 01 D8 C0 00 00 00 00 00 00 00 00 FF 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 01 80 30 F0 00 00 0F C0 01 C0 76 00 0E 07 0C 00 30 F3 C3 F0 03 8E C0 00 00 00 00 00 00 00 03 FF 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 03 00 30 70 00 00 00 00 03 80 3E 00 00 01 CE 00 60 73 80 00 06 07 C0 00 00 00 00 00 00 00 03 FF 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 30 00 00 00 00 06 00 1C 00 00 00 7E 00 00 33 00 00 0C 03 80 00 00 00 00 00 00 00 1F FE 00 00 00 00 1F F0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 1C 00 0C 00 00 00 00 00 00 00 00 00 38 01 80 00 00 00 00 00 00 00 1F FE 00 00 00 00 3F E0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 1F FC 00 00 00 00 FF E0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 1F FC 00 00 00 00 FF E0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 FF C0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 03 FF 80 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 03 FF 80 00 00 00 01 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 07 FF 80 00 21 E0 01 83 00 00 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 02 00 00 00 00 00 0F FF 00 00 3E 40 01 02 00 00 1E 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 02 00 00 00 00 00 0F FF 00 00 27 80 01 02 60 21 E4 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 3F F8 00 00 78 80 02 3F 80 10 48 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 01 00 00 00 00 00 7F F0 00 00 40 80 02 44 00 10 30 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 01 C0 00 00 00 01 FF E0 00 00 4F 80 1F 87 80 02 3E 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 01 C0 00 00 00 01 FF E0 00 00 F8 00 24 79 00 03 C2 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 C0 00 00 00 03 FF C0 00 00 A0 00 04 09 E0 12 44 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 E0 00 00 00 0F FF 00 00 00 47 E0 06 FF 03 E3 F4 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 E0 00 00 00 0F FF 00 00 00 FA 40 19 12 00 44 88 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 38 00 00 00 3F FC 00 00 03 24 80 68 1E 00 44 88 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 1F 00 00 03 FF F8 00 00 04 48 81 8B F0 00 47 E8 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 07 80 00 0F FF F0 00 00 18 91 00 11 20 00 49 10 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 07 80 00 0F FF F0 00 00 23 22 00 11 3C 00 89 10 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 03 FC 03 FF FF 80 00 00 04 42 00 12 20 00 9A A0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 03 FC 03 FF FF 80 00 00 18 84 00 23 C0 0F D2 60 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 FF FF FF FC 00 00 00 23 28 01 24 60 00 38 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 7F FF FF F0 00 00 00 0C 30 00 C8 18 00 07 8C 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 0F FF FF 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 FF E0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 FF E0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 FF E0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ";
        bSendData = hexStringToBytes(strdata);
        mUsbDriver.write(bSendData);*/
        PrintFeedDot(20);
        //int cutPaper = Integer.parseInt(cutMode);

        //mUsbDriver.write(PrintCmd.PrintFeedline(5));
        //mUsbDriver.write(PrintCmd.PrintCutpaper(cutPaper));

    }

    public void execute_reserve_printCut(UsbDriver mUsbDriver,String cutMode){

        //PrintFeedDot(5);
        int cutPaper = Integer.parseInt(cutMode);

        mUsbDriver.write(PrintCmd.PrintFeedline(5));
        mUsbDriver.write(PrintCmd.PrintCutpaper(cutPaper));

    }

    public void setPrintPaperSize(UsbDriver mUsbDriver,String checkedType){

        byte[] bSendData;
        String strdata;
        if(checkedType == "1"){
            strdata = "13 74 44 88 10";
        }else{
            strdata = "13 74 44 88 30";
        }

        bSendData = hexStringToBytes(strdata);
        //mUsbDriver.write(bSendData);
        //打印测试页
        mUsbDriver.write(PrintCmd.PrintSelfcheck());
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
