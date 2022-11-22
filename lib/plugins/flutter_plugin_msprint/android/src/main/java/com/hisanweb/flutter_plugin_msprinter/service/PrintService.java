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

import com.hisanweb.flutter_plugin_msprinter.reserveInfo.ReserveList;

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
