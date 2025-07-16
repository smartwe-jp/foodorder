package com.diancan.appset;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.app.AlarmManager;
import android.app.PendingIntent;
import android.os.Bundle;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** AppsetPlugin */
public class AppsetPlugin implements FlutterPlugin, MethodCallHandler {
  private MethodChannel channel;
  private Context mContext;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "appset");
    channel.setMethodCallHandler(this);
    mContext = flutterPluginBinding.getApplicationContext();
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else if (call.method.equals("showBullyScreen")) {
      Intent statusbarIntent = new Intent("com.android.SHOW_STATUSBAR");
      mContext.sendBroadcast(statusbarIntent);

      Intent navabarIntent = new Intent("com.android.SHOW_NAVBAR");
      mContext.sendBroadcast(navabarIntent);
      result.success("success");
    } else if (call.method.equals("hideBullyScreen")) {
      Intent statusbarIntent = new Intent("com.android.HIDE_STATUSBAR");
      mContext.sendBroadcast(statusbarIntent);

      Intent navabarIntent = new Intent("com.android.HIDE_NAVBAR");
      mContext.sendBroadcast(navabarIntent);
      result.success("success");
    } else if (call.method.equals("restartApp")) {
      restartApp();
      result.success("success");
    } else {
      result.notImplemented();
    }
  }

  private void restartApp() {
    Intent intent = mContext.getPackageManager()
            .getLaunchIntentForPackage(mContext.getPackageName());
    PendingIntent restartIntent = PendingIntent.getActivity(mContext, 0, intent, PendingIntent.FLAG_ONE_SHOT);
    AlarmManager mgr = (AlarmManager) mContext.getSystemService(Context.ALARM_SERVICE);
    mgr.set(AlarmManager.RTC, System.currentTimeMillis() + 1000, restartIntent);
    System.exit(0);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}