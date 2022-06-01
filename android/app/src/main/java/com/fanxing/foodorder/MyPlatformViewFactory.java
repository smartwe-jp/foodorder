package com.fanxing.foodorder;

import android.content.Context;

import io.flutter.Log;
import io.flutter.plugin.common.MessageCodec;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class MyPlatformViewFactory extends PlatformViewFactory {

    private MethodChannel mChannel;
    public MyPlatformView mMyPlatformView;

    public MyPlatformViewFactory(MessageCodec<Object> createArgsCodec, MethodChannel channel) {
        super(createArgsCodec);
        mChannel = channel;
    }

    /**
     *
     * @param context
     * @param viewId 在Flutter端AndroidView的唯一识别id
     * @param args Flutter端AndroidView传递过来的参数
     * @return
     */
    @Override
    public PlatformView create(Context context, int viewId, Object args) {
        //Log.d("MyPlatformViewFactory","来了MyPlatformViewFactory");
        mMyPlatformView = new MyPlatformView(context,mChannel);
        return mMyPlatformView;
    }

}
