package com.diancan.appset;

import android.content.Context;
import android.content.Intent;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** AppsetPlugin */
public class AppsetPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
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
    }else if(call.method.equals("showBullyScreen")){
      Intent statusbarIntent = new Intent("com.android.SHOW_STATUSBAR");
      mContext.sendBroadcast(statusbarIntent);

      Intent navabarIntent = new Intent("com.android.SHOW_NAVBAR");
      mContext.sendBroadcast(navabarIntent);
      result.success("success");
    }else if(call.method.equals("hideBullyScreen")){
      Intent statusbarIntent = new Intent("com.android.HIDE_STATUSBAR");
      mContext.sendBroadcast(statusbarIntent);

      Intent navabarIntent = new Intent("com.android.HIDE_NAVBAR");
      mContext.sendBroadcast(navabarIntent);
      result.success("success");
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
