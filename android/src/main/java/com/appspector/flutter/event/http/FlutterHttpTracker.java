package com.appspector.flutter.event.http;

import com.appspector.sdk.monitors.http.HttpMonitorObserver;
import com.appspector.sdk.monitors.http.HttpRequest;
import com.appspector.sdk.monitors.http.HttpResponse;

import java.util.Map;

final class FlutterHttpTracker {

    private static final String TRACKER_ID = "flutter_client_io";

    private FlutterHttpTracker() {
    }

    @SuppressWarnings({"ConstantConditions", "unchecked"})
    static void trackResponse(Map<String, Object> response) {
        Object tookMs = response.get("tookMs");
        HttpMonitorObserver.getTracker(TRACKER_ID).track(new HttpResponse.Builder()
                .requestUid((String) response.get("uid"))
                .code((int) response.get("code"))
                .error((String) response.get("error"))
                .body((byte[]) response.get("body"))
                .tookMs(tookMs instanceof Long ? (Long) tookMs : ((Integer) tookMs).longValue())
                .addHeaders((Map<String, String>) response.get("headers"))
                .build());
    }

    @SuppressWarnings({"ConstantConditions", "unchecked"})
    static void trackRequest(Map<String, Object> requestData) {
        HttpMonitorObserver.getTracker(TRACKER_ID).track(new HttpRequest.Builder()
                .uid((String) requestData.get("uid"))
                .url((String) requestData.get("url"))
                .addHeaders((Map<String, String>) requestData.get("headers"))
                .method((String) requestData.get("method"), (byte[]) requestData.get("body"))
                .build());
    }
}
