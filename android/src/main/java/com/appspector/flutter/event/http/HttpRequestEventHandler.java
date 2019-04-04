package com.appspector.flutter.event.http;

import com.appspector.flutter.event.EventHandler;

import java.util.Map;

import io.flutter.plugin.common.MethodCall;

public final class HttpRequestEventHandler extends EventHandler {

    @Override
    public String eventName() {
        return "http-request";
    }

    @Override
    @SuppressWarnings("unchecked")
    public void handle(MethodCall call) {
        final Map<String, Object> requestData = (Map<String, Object>) call.arguments;
        FlutterHttpTracker.trackRequest(requestData);
    }
}
