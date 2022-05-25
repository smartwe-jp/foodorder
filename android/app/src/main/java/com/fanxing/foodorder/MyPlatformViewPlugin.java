package com.fanxing.foodorder;

import android.content.Context;
import io.flutter.Log;

import androidx.annotation.NonNull;

import com.deptrum.usblite.callback.IDeviceListener;
import com.deptrum.usblite.sdk.DeptrumSdkApi;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.StandardMessageCodec;

/** DeptrumApiPlugin */
public class MyPlatformViewPlugin implements FlutterPlugin, MethodChannel.MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel mChannel;
  private MyPlatformViewFactory mMyPlatformViewFactory;
  private Context mContext;


  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    mChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "plugins.com.fanxing.foodorder/faceSwipingApi");
    mChannel.setMethodCallHandler(this);

    //mContext = flutterPluginBinding.getApplicationContext();
    //DeptrumSdkApi.getApi().open(flutterPluginBinding.getApplicationContext(), (IDeviceListener) this);

    Log.d("MyPlatformViewPlugin","来了");
    //创建PlatformView的工厂对象
    mMyPlatformViewFactory = new MyPlatformViewFactory(StandardMessageCodec.INSTANCE,mChannel);
    //在Flutter引擎上注册PlatformView的工厂对象
    flutterPluginBinding.getPlatformViewRegistry().registerViewFactory("plugins.com.fanxing.foodorder/android_view",mMyPlatformViewFactory);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    //注销通道的监听
    mChannel.setMethodCallHandler(null);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else if(call.method.equals("takePictureButtonAndNoticeAndroid")){

      String flutterButtonClickedNumber = call.argument("takePicture");
      mMyPlatformViewFactory.mMyPlatformView.backCameraImageBitmap(flutterButtonClickedNumber);

      //mMyPlatformViewFactory.mMyPlatformView.showFlutterButtonClickedNumber();
      result.success("success");
    } else if(call.method.equals("stopPictureButtonAndNoticeAndroid")){
      mMyPlatformViewFactory.mMyPlatformView.stopCameraImage();

      //mMyPlatformViewFactory.mMyPlatformView.showFlutterButtonClickedNumber();
      result.success("success");
    } else if(call.method.equals("getCameraImage")){
      result.success("success");
    } else {
      result.notImplemented();
    }
  }


}
