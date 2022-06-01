package com.fanxing.foodorder;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;

public class MainActivity extends FlutterActivity {
    /*private Context mContext;


   @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
       mContext = this;
        if(mContext != null){
            Intent statusbarIntent = new Intent("com.android.HIDE_STATUSBAR");
            mContext.sendBroadcast(statusbarIntent);

            Intent navabarIntent = new Intent("com.android.HIDE_NAVBAR");
            mContext.sendBroadcast(navabarIntent);

        }
    }*/

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        //注册插件
        flutterEngine.getPlugins().add(new MyPlatformViewPlugin());
    }

}
