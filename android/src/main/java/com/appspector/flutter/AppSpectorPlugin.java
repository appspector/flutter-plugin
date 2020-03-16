package com.appspector.flutter;

import android.app.Application;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.appspector.flutter.event.EventReceiver;
import com.appspector.flutter.event.http.HttpRequestEventHandler;
import com.appspector.flutter.event.http.HttpResponseEventHandler;
import com.appspector.flutter.event.log.LogEventHandler;
import com.appspector.flutter.screenshot.FlutterScreenshotFactory;
import com.appspector.sdk.AppSpector;
import com.appspector.sdk.Builder;
import com.appspector.sdk.core.util.AppspectorLogger;
import com.appspector.sdk.monitors.screenshot.ScreenshotMonitor;

import java.util.Collections;
import java.util.List;
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
    @SuppressWarnings({"FieldCanBeLocal", "unused"})
    private final EventReceiver eventReceiver;
    private final RequestSender requestSender;

    private AppSpectorPlugin(Application application,
                             EventReceiver eventReceiver,
                             RequestSender requestSender) {
        this.application = application;
        this.eventReceiver = eventReceiver;
        this.requestSender = requestSender;
        registerEvents(eventReceiver);
    }

    private void registerEvents(EventReceiver eventReceiver) {
        eventReceiver.registerEventHandler(new HttpRequestEventHandler());
        eventReceiver.registerEventHandler(new HttpResponseEventHandler());
        eventReceiver.registerEventHandler(new LogEventHandler());
    }

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "appspector_plugin");
        final MethodChannel eventChannel = new MethodChannel(registrar.messenger(), "appspector_event_channel");
        final MethodChannel requestChannel = new MethodChannel(registrar.messenger(), "appspector_request_channel");

        channel.setMethodCallHandler(new AppSpectorPlugin(
                (Application) registrar.context().getApplicationContext(),
                new EventReceiver(eventChannel),
                new RequestSender(requestChannel)
        ));
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch (call.method) {
            case "run":
                initAppSpector(result,
                        call.<String>argument("apiKey"),
                        call.<Map<String, String>>argument("metadata"),
                        call.<List<String>>argument("enabledMonitors")
                );
                break;
            case "stop":
                pauseSdk(result);
                break;
            case "start":
                resumeSdk(result);
                break;
            case "isStarted":
                checkSdkStarted(result);
                break;
            default:
                result.notImplemented();
        }
    }

    private void checkSdkStarted(@NonNull Result result) {
        final AppSpector sharedInstance = AppSpector.shared();
        if (sharedInstance != null) {
            result.success(sharedInstance.isStarted());
        } else {
            result.error("NotInitialized", "AppSpector shared instance is null", null);
        }
    }

    private void pauseSdk(@NonNull Result result) {
        final AppSpector sharedInstance = AppSpector.shared();
        if (sharedInstance != null) {
            sharedInstance.stop();
            result.success(null);
        } else {
            result.error("NotInitialized", "AppSpector shared instance is null", null);
        }
    }

    private void resumeSdk(@NonNull Result result) {
        final AppSpector sharedInstance = AppSpector.shared();
        if (sharedInstance != null) {
            sharedInstance.start();
            result.success(null);
        } else {
            result.error("NotInitialized", "AppSpector shared instance is null", null);
        }
    }

    private void initAppSpector(@NonNull Result result, @Nullable String apiKey, @Nullable Map<String, String> metadata, @Nullable List<String> enabledMonitors) {
        if (apiKey == null) {
            result.error("MissingAppKey", "Cannot initialize SDK without AppKey", null);
            return;
        }

        final Builder builder = AppSpector.build(application)
                .addMetadata(metadata != null ? metadata : Collections.<String, String>emptyMap());

        addMonitors(builder, enabledMonitors);


        builder.run(apiKey);
    }

    private void addMonitors(@NonNull Builder builder, @Nullable List<String> enabledMonitors) {
        if (enabledMonitors == null || enabledMonitors.isEmpty()) {
            builder
                    .withDefaultMonitors()
                    .addMonitor(new ScreenshotMonitor(new FlutterScreenshotFactory(requestSender)));
            return;
        }

        for (String monitor : enabledMonitors) {
            switch (monitor) {
                case "logs":
                    builder.addLogMonitor();
                    break;
                case "screenshot":
                    builder.addMonitor(new ScreenshotMonitor(new FlutterScreenshotFactory(requestSender)));
                    break;
                case "environment":
                    builder.addEnvironmentMonitor();
                    break;
                case "http":
                    builder.addHttpMonitor();
                    break;
                case "location":
                    builder.addLocationMonitor();
                    break;
                case "performance":
                    builder.addPerformanceMonitor();
                    break;
                case "sqlite":
                    builder.addSQLMonitor();
                    break;
                case "shared-preferences":
                    builder.addSharedPreferenceMonitor();
                    break;
                default:
                    AppspectorLogger.d("Unknown monitor: %s", monitor);
            }
        }
    }
}
