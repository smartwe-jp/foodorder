package com.fanxing.foodorder;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

import androidx.annotation.NonNull;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;

public class MainActivity extends FlutterActivity {
    private Context mContext;

    private ScheduledExecutorService threadPool = null;
    private int betweenTime = 59;//间隔59秒执行一次
    private int delayTime = 50;//线程池开启5秒后执行
    private String time = "07:00";//重启时间一
    SimpleDateFormat sdf = new SimpleDateFormat("HH:mm", Locale.CHINA);
    String dateStr = "";//获取的时间
   @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
       /*mContext = this;
        if(mContext != null){
            Intent statusbarIntent = new Intent("com.android.HIDE_STATUSBAR");
            mContext.sendBroadcast(statusbarIntent);

            Intent navabarIntent = new Intent("com.android.HIDE_NAVBAR");
            mContext.sendBroadcast(navabarIntent);

        }*/

       threadPool = Executors.newScheduledThreadPool(3);
       executeShutDown();
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        //注册插件
        flutterEngine.getPlugins().add(new MyPlatformViewPlugin());
    }

    public void executeShutDown() {
        Log.d("重启executeShutDown", "=executeShutDownexecuteShutDownexecuteShutDown");
        threadPool.scheduleAtFixedRate(new Runnable() {
            @Override
            public void run() {
                dateStr = sdf.format(new Date());
                Log.d("重启", dateStr.equals(time) + "=" + dateStr);
                // root机子
                if (dateStr.equals(time)) {
                    //重启广播
                    Intent intent1 = new Intent("com.sed.ctrl.ps.REQUEST_REBOOT");//重启
                    sendBroadcast(intent1);
                    /*try {
                        Runtime.getRuntime().exec(rebootArray);
                        exec("reboot");
                    } catch (IOException io) {
                        io.printStackTrace();
                    }*/
                }
            }
        }, delayTime, betweenTime, TimeUnit.SECONDS);
    }

}
