package com.appspector.flutter.event.http;

import com.appspector.flutter.event.Event;

import java.util.Map;

import io.flutter.plugin.common.MethodCall;

public final class HttpResponseEvent extends Event {

    @Override
    public String eventName() {
        return "http-response";
    }

    @Override
    @SuppressWarnings("unchecked")
    public void track(MethodCall call) {
        final Map<String, Object> responseData = (Map<String, Object>) call.arguments;
        FlutterHttpTracker.trackResponse(responseData);
    }
}
