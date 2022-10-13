package com.fanxing.foodorder;

import io.flutter.Log;
import android.content.Context;
import android.graphics.Bitmap;
import android.util.Base64;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;

import com.deptrum.usblite.callback.IDeviceListener;
import com.deptrum.usblite.callback.IStreamListener;


import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

import com.fanxing.foodorder.opengl.GLDisplay;
import com.fanxing.foodorder.opengl.GLFrameSurface;

import com.deptrum.usblite.param.DTFrameStreamBean;
import com.deptrum.usblite.param.StreamType;
import com.deptrum.usblite.sdk.DeptrumSdkApi;

import java.io.ByteArrayOutputStream;
import java.nio.ByteBuffer;
import java.util.HashMap;
import java.util.Map;


public class MyPlatformView implements PlatformView,IDeviceListener, IStreamListener  {

    private Context mContext;

    private GLFrameSurface mRgbSurface;

    private GLDisplay mRgbisplay;
    private View mNativeView;
    //private Button mBtnPhoto;
    private byte[] mImage;


    private MethodChannel mChannel;

    private Bitmap mRGBBitmap = null;
    private byte[] mRgbBits = null;
    private int mRgbLength = 0;



    public MyPlatformView(Context context, MethodChannel channel) {
        //io.flutter.Log.d("MyPlatformView","来打开相机了");

        mChannel = channel;
        //setContentView(initUI(mContext));

        mNativeView = LayoutInflater.from(context).inflate(R.layout.activity_main,null,false);
        mContext = context.getApplicationContext();

        //super.onCreate(savedInstanceState);
        mRgbSurface = mNativeView.findViewById(R.id.gl_rgb);
        //mBtnPhoto = mNativeView.findViewById(R.id.btn_photo);

        mRgbisplay = new GLDisplay();


        openDevice(context);
        //String apiresult = DeptrumSdkApi.getApi().getSupportInfo();
        //io.flutter.Log.d("apiresult","相机状态----------"+apiresult);

        //noticeFlutterPhoto();
        //点击安卓按钮并将安卓按钮点击数量通知Flutter端
        /*mBtnPhoto.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                convertRGBToRGBA(mImage,480,768);
                ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
                mRGBBitmap.compress(Bitmap.CompressFormat.PNG, 100, outputStream);
                String resultImage = Base64.encodeToString(outputStream.toByteArray(), Base64.DEFAULT);

                Map<String,String> map = new HashMap<>();
                map.put("AndroidResultImage",resultImage+"");
                mChannel.invokeMethod("clickAndroidButtonAndNoticeFlutter",map);
            }
        });*/
    }


    private void openDevice(Context context) {
        DeptrumSdkApi.getApi().open(context.getApplicationContext(), this);
    }


    /**
     * 返回嵌入到Flutter页面中的安卓原生view
     * @return
     */
    @Override
    public View getView() {
        return mNativeView;
    }


    @Override
    public void dispose() {

        DeptrumSdkApi.getApi().stopStream(StreamType.STREAM_RGB);
        //DeptrumSdkApi.getApi().setStreamListener(null);
        DeptrumSdkApi.getApi().close();
        mRgbSurface.onPause();

        mRgbisplay.release();
        mRgbisplay=null;
    }


    @Override
    public void onAttach() {

    }

    @Override
    public void onDetach() {

    }

    @Override
    public void onOpenResult(int result) {
        if (0 == result){

            DeptrumSdkApi.getApi().setStreamListener(this);
            DeptrumSdkApi.getApi().setScanFaceMode();
            DeptrumSdkApi.getApi().startStream(StreamType.STREAM_RGB);
        }
        else {

        }
    }

    @Override
    public void onErrorEvent(String s, int i) {

    }

    @Override
    public void onFrame(DTFrameStreamBean iFrame) {
        //Log.d("apiresult", "相机IStreamListener状态----------88888888888888");
        byte[] data = iFrame.getData();
        mImage = iFrame.getData();

        //Log.d("apiresult", "相机mRgbisplay.render状态----------7777777" + mImage);
        switch (iFrame.getImageType()) {
            case RGB: {
                if (null != data) {
                    mRgbSurface.post(() -> {
                        if (null != mRgbisplay && null != mRgbSurface) {
                            mRgbisplay.render(mRgbSurface, 0, false, data,
                                    480, 768, 1);
                        }
                    });
                }
            }
            break;
        }
    }

    public void convertRGBToRGBA(byte[] data, int width, int height) {
        try {
            int len = data.length / 3 * 4;
            if (null == mRgbBits || len != mRgbLength){
                mRgbBits = new byte[data.length / 3 * 4]; // RGBA 数组
                mRgbLength = data.length / 3 * 4;
            }

//            byte[] Bits = new byte[data.length / 3 * 4]; // RGBA 数组
            int i;
            for (i = 0; i < data.length / 3; i++) {
                // 原理：4个字节表示一个灰度，则RGB  = 灰度值，最后一个Alpha = 0xff;
                mRgbBits[i * 4] = data[i * 3];
                mRgbBits[i * 4 + 1] = data[i * 3 + 1];
                mRgbBits[i * 4 + 2] = data[i * 3 + 2];
                mRgbBits[i * 4 + 3] = -1; // 0xff
            }

            // Bitmap.Config.ARGB_8888 表示：图像模式为8位
            if (null == mRGBBitmap){
                mRGBBitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
            }
            mRGBBitmap.copyPixelsFromBuffer(ByteBuffer.wrap(mRgbBits));

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * Flutter的按钮被点击打卡
     * 安卓返回相片数据
     */
    public void backCameraImageBitmap(String number){
        convertRGBToRGBA(mImage,480,768);
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        mRGBBitmap.compress(Bitmap.CompressFormat.PNG, 100, outputStream);
        String resultImage = (outputStream.toByteArray() != null && outputStream.toByteArray().length != 0) ? Base64.encodeToString(outputStream.toByteArray(), Base64.DEFAULT) : "ERROR";

        Map<String,String> map = new HashMap<>();
        map.put("AndroidResultImage",resultImage+"");
        mChannel.invokeMethod("clickAndroidButtonAndNoticeFlutter",map);
    }

    public void stopCameraImage(){
        DeptrumSdkApi.getApi().stopStream(StreamType.STREAM_RGB);
        //DeptrumSdkApi.getApi().setStreamListener(null);

        DeptrumSdkApi.getApi().close();

        //mRgbSurface.onPause();

        //mRgbisplay.release();
        //mRgbisplay=null;
    }

}
