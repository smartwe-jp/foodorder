package com.fanxing.foodorder;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;

import io.flutter.embedding.android.FlutterActivity;

public class MainActivity extends FlutterActivity {
    private Context mContext;


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
    }

}
