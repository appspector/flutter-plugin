package com.appspector.flutter.plugin;

import android.app.Application;
import android.util.Log;

import com.appspector.sdk.AppSpector;
import com.appspector.sdk.core.util.AppspectorLogger;

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

    private Application application;

    private AppSpectorPlugin(Application application) {
        this.application = application;
    }

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "appspector_plugin");
        channel.setMethodCallHandler(new AppSpectorPlugin((Application) registrar.context().getApplicationContext()));
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        Log.d("AppSpectorPlugin", "onMethodCall");
        switch (call.method) {
            case "getPlatformVersion":
                result.success("Android " + android.os.Build.VERSION.RELEASE);
                break;

            case "initSDK":
                @SuppressWarnings("unchecked")
                Map<String, Object> configs = (Map<String, Object>) call.arguments;
                initAppSpector((String) configs.get("androidApiKey"), (Boolean) configs.get("debugLogging"));
                break;
            default:
                result.notImplemented();
        }
    }

    private void initAppSpector(String apiKey, Boolean enableDebugLogging) {
        Log.d("AppSpectorPlugin", "initAppSpector");
        AppSpector.build(application)
                .withDefaultMonitors()
                .run(apiKey);
        if (enableDebugLogging != null) {
            AppspectorLogger.AndroidLogger.enableDebugLogging(enableDebugLogging);
        }
    }
}
