package com.appspector.flutter;

import android.os.Handler;

import io.flutter.plugin.common.MethodChannel;

public class RequestSender {

    private final MethodChannel methodChannel;
    private final Handler handler = new Handler();

    public RequestSender(MethodChannel requestMethodChannel) {
        this.methodChannel = requestMethodChannel;
    }

    public void executeRequest(final String requestName, final Object args, final ResponseCallback callback) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                methodChannel.invokeMethod(requestName, args, new MethodChannel.Result() {
                    @Override
                    public void success(Object o) {
                        callback.onSuccess(o);
                    }

                    @Override
                    public void error(String s, String s1, Object o) {
                        callback.onError(s + " " + s1);
                    }

                    @Override
                    public void notImplemented() {
                        callback.onError(String.format("%s method is not implemented", requestName));
                    }
                });
            }
        });
    }

    public interface ResponseCallback {

        void onSuccess(Object result);

        void onError(String message);
    }
}
