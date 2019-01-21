package com.appspector.flutter.screenshot;

import com.appspector.sdk.monitors.screenshot.ScreenshotCallback;
import com.appspector.sdk.monitors.screenshot.ScreenshotFactory;

import java.util.HashMap;

import io.flutter.plugin.common.MethodChannel;

public class FlutterScreenshotFactory implements ScreenshotFactory {

    private final MethodChannel methodChannel;

    public FlutterScreenshotFactory(MethodChannel methodChannel) {
        this.methodChannel = methodChannel;
    }

    @Override
    public void takeScreenshot(int maxWidth, int quality, final ScreenshotCallback screenshotCallback) {
        final HashMap<String, Integer> args = new HashMap<>();
        args.put("max_width", maxWidth);
        args.put("quality", quality);
        methodChannel.invokeMethod("take_screenshot", args, new MethodChannel.Result() {
            @Override
            public void success(Object o) {
                screenshotCallback.onSuccess((byte[]) o);
            }

            @Override
            public void error(String s, String s1, Object o) {
                screenshotCallback.onError(s + " " + s1);
            }

            @Override
            public void notImplemented() {
                screenshotCallback.onError("take_screenshot method is not implemented");
            }
        });
    }
}
