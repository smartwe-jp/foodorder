package com.hisanweb.flutter_plugin_msprinter.msprintsdk;

import java.util.concurrent.Callable;

public class HttpCallable implements Callable<byte[]> {
    private String imgUrl;

    public HttpCallable(String imgUrl){
        this.imgUrl = imgUrl;
    }

    @Override
    public byte[] call() throws Exception {
        return PrintCmd.PrintDiskImageUrl(imgUrl);
    }
}
