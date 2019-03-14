package com.appspector.flutter.screenshot;

import com.appspector.flutter.RequestSender;
import com.appspector.sdk.monitors.screenshot.ScreenshotCallback;
import com.appspector.sdk.monitors.screenshot.ScreenshotFactory;

import java.util.HashMap;

public class FlutterScreenshotFactory implements ScreenshotFactory {

    private final RequestSender requestSender;

    public FlutterScreenshotFactory(RequestSender requestSender) {
        this.requestSender = requestSender;
    }

    @Override
    public void takeScreenshot(int maxWidth, int quality, final ScreenshotCallback screenshotCallback) {
        final HashMap<String, Integer> args = new HashMap<>();
        args.put("max_width", maxWidth);
        args.put("quality", quality);
        requestSender.executeRequest("take_screenshot", args, new RequestSender.ResponseCallback() {
            @Override
            public void onSuccess(Object result) {
                screenshotCallback.onSuccess((byte[]) result);
            }

            @Override
            public void onError(String message) {
                screenshotCallback.onError(message);
            }
        });
    }
}
