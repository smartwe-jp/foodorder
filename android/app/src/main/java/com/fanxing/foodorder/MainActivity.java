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

import android.net.wifi.WifiManager;
import android.os.PowerManager; // 导入 PowerManager
import io.flutter.embedding.android.FlutterActivity;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;

public class MainActivity extends FlutterActivity {
    private Context mContext;
    private PowerManager.WakeLock wakeLock; // CPU 唤醒锁
    private WifiManager.WifiLock wifiLock;

    //private ScheduledExecutorService threadPool = null;
    //private int betweenTime = 59;//间隔59秒执行一次
    //private int delayTime = 50;//线程池开启5秒后执行
    //private String time = "06:00";//重启时间一
    //SimpleDateFormat sdf = new SimpleDateFormat("HH:mm", Locale.CHINA);
    //String dateStr = "";//获取的时间
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

       //threadPool = Executors.newScheduledThreadPool(3);
       //executeShutDown();
       // 获取 PowerManager 实例
       PowerManager powerManager = (PowerManager) getSystemService(Context.POWER_SERVICE);
       // 创建 CPU 唤醒锁：PARTIAL_WAKE_LOCK 确保 CPU 运行，即使屏幕关闭
       // 鉴于你的应用始终在前台，也可以考虑 SCREEN_BRIGHT_WAKE_LOCK 或 FULL_WAKE_LOCK 来保持屏幕常亮
       // 但 PARTIAL_WAKE_LOCK 已经足以保持网络连接和CPU活跃。
       wakeLock = powerManager.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "YourApp::MainCpuWakeLockTag");

       // 获取 WifiManager 实例
       WifiManager wifiManager = (WifiManager) getApplicationContext().getSystemService(Context.WIFI_SERVICE);
       // 创建 Wi-Fi 唤醒锁：WIFI_MODE_FULL_HIGH_PERF 确保 Wi-Fi 处于高性能模式
       // 如果你的目标 API 级别低于 29，可以使用 WIFI_MODE_FULL
       wifiLock = wifiManager.createWifiLock(WifiManager.WIFI_MODE_FULL_HIGH_PERF, "YourApp::MainWifiLockTag");

       // 在应用启动时获取唤醒锁
       if (wakeLock != null && !wakeLock.isHeld()) {
           wakeLock.acquire();
           System.out.println("CPU Wake Lock acquired in MainActivity");
       }
       if (wifiLock != null && !wifiLock.isHeld()) {
           wifiLock.acquire();
           System.out.println("Wi-Fi Lock acquired in MainActivity");
       }

    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        //注册插件
        flutterEngine.getPlugins().add(new MyPlatformViewPlugin());
    }

    /*public void executeShutDown() {
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
                    *//*try {
                        Runtime.getRuntime().exec(rebootArray);
                        exec("reboot");
                    } catch (IOException io) {
                        io.printStackTrace();
                    }*//*
                }
            }
        }, delayTime, betweenTime, TimeUnit.SECONDS);
    }*/
    @Override
    protected void onDestroy() {
        super.onDestroy();
        // 在应用销毁时释放唤醒锁
        if (wakeLock != null && wakeLock.isHeld()) {
            wakeLock.release();
            System.out.println("CPU Wake Lock released in MainActivity");
        }
        if (wifiLock != null && wifiLock.isHeld()) {
            wifiLock.release();
            System.out.println("Wi-Fi Lock released in MainActivity");
        }
    }

}
