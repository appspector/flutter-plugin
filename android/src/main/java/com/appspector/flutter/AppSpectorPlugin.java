package com.appspector.flutter;

import android.app.Application;

import com.appspector.flutter.screenshot.FlutterScreenshotFactory;
import com.appspector.sdk.AppSpector;
import com.appspector.sdk.monitors.http.HttpMonitor;
import com.appspector.sdk.monitors.screenshot.ScreenshotMonitor;

import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * AppSpectorPlugin
 */
public class AppSpectorPlugin implements MethodCallHandler {

    private final Application application;
    private final MethodChannel channel;

    private AppSpectorPlugin(Application application, MethodChannel channel) {
        this.application = application;
        this.channel = channel;
    }

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "appspector_plugin");
        channel.setMethodCallHandler(new AppSpectorPlugin(
                (Application) registrar.context().getApplicationContext(),
                channel
        ));
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        switch (call.method) {
            case "run":
                @SuppressWarnings("unchecked")
                Map<String, Object> configs = (Map<String, Object>) call.arguments;
                initAppSpector((String) configs.get("apiKey"));
                break;
            default:
                result.notImplemented();
        }
    }

    private void initAppSpector(String apiKey) {
        AppSpector.build(application)
                .withDefaultMonitors()
                .addMonitor(new ScreenshotMonitor(new FlutterScreenshotFactory(channel)))
                .removeMonitor(HttpMonitor.class)
                .run(apiKey);
    }
}
