package com.appspector.flutter;

import android.util.Log;

import io.flutter.plugin.common.MethodChannel;

public class RequestSender {

    private final MethodChannel methodChannel;

    public RequestSender(MethodChannel requestMethodChannel) {
        this.methodChannel = requestMethodChannel;
    }

    public void executeRequest(final String requestName, Object args, final ResponseCallback callback) {
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

    public interface ResponseCallback {

        void onSuccess(Object result);

        void onError(String message);
    }
}
