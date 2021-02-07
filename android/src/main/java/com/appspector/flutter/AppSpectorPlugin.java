package com.appspector.flutter;

import android.app.Application;
import android.os.Handler;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.appspector.flutter.event.EventReceiver;
import com.appspector.flutter.event.http.HttpRequestEventHandler;
import com.appspector.flutter.event.http.HttpResponseEventHandler;
import com.appspector.flutter.event.log.LogEventHandler;
import com.appspector.flutter.screenshot.FlutterScreenshotFactory;
import com.appspector.sdk.AppSpector;
import com.appspector.sdk.Builder;
import com.appspector.sdk.SessionUrlListener;
import com.appspector.sdk.core.util.AppspectorLogger;
import com.appspector.sdk.monitors.screenshot.ScreenshotMonitor;

import java.util.Collections;
import java.util.HashMap;
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
    private final SessionUrlListener sessionUrlListener;
    private final Map<String, MonitorInitializer> monitorInitializerMap;

    private AppSpectorPlugin(Application application,
                             SessionUrlListener sessionUrlListener,
                             EventReceiver eventReceiver,
                             RequestSender requestSender) {
        this.application = application;
        this.eventReceiver = eventReceiver;
        this.requestSender = requestSender;
        this.sessionUrlListener = sessionUrlListener;
        this.monitorInitializerMap = createMonitorInitializerMap();
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
        final Handler mainHandler = new Handler();
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "appspector_plugin");
        final MethodChannel eventChannel = new MethodChannel(registrar.messenger(), "appspector_event_channel");
        final MethodChannel requestChannel = new MethodChannel(registrar.messenger(), "appspector_request_channel");

        channel.setMethodCallHandler(new AppSpectorPlugin(
                (Application) registrar.context().getApplicationContext(),
                new InternalAppSpectorSessionListener(mainHandler, channel),
                new EventReceiver(eventChannel),
                new RequestSender(mainHandler, requestChannel)
        ));
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch (call.method) {
            case "run":
                initAppSpector(result,
                        call.argument("apiKey"),
                        call.argument("metadata"),
                        call.argument("enabledMonitors")
                );
                break;
            case "stop":
                stopSdk(result);
                break;
            case "start":
                startSdk(result);
                break;
            case "isStarted":
                checkSdkStarted(result);
                break;
            case "setMetadata":
                setMetadata(call.argument("key"), call.argument("value"), result);
                break;
            case "removeMetadata":
                removeMetadata(call.argument("key"), result);
                break;
            default:
                result.notImplemented();
        }
    }

    private void setMetadata(@Nullable String key, @Nullable String value, @NonNull Result result) {
        if (key == null || value == null) {
            AppspectorLogger.e("AppSpectorPlugin :: key or value is null");
            return;
        }
        withSharedInstance(result, sharedInstance -> {
            sharedInstance.setMetadataValue(key, value);
            return null;
        });
    }

    private void removeMetadata(@Nullable String key, @NonNull Result result) {
        if (key == null) {
            AppspectorLogger.e("AppSpectorPlugin :: key is null");
            return;
        }
        withSharedInstance(result, sharedInstance -> {
            sharedInstance.removeMetadataValue(key);
            return null;
        });
    }

    private void checkSdkStarted(@NonNull Result result) {
        withSharedInstance(result, AppSpector::isStarted);
    }

    private void stopSdk(@NonNull Result result) {
        withSharedInstance(result, sharedInstance -> {
            sharedInstance.stop();
            return null;
        });
    }

    private void startSdk(@NonNull Result result) {
        withSharedInstance(result, sharedInstance -> {
            sharedInstance.start();
            return null;
        });
    }

    private void initAppSpector(@NonNull Result result, @Nullable String apiKey, @Nullable Map<String, String> metadata, @Nullable List<String> enabledMonitors) {
        if (apiKey == null) {
            result.error("MissingAppKey", "Cannot initialize SDK without AppKey", null);
            return;
        }

        final Builder builder = AppSpector.build(application)
                .addMetadata(metadata != null ? metadata : Collections.emptyMap());

        addMonitors(builder, enabledMonitors);

        builder.run(apiKey);

        //noinspection ConstantConditions
        AppSpector.shared().setSessionUrlListener(sessionUrlListener);
    }

    private Map<String, MonitorInitializer> createMonitorInitializerMap() {
        return new HashMap<String, MonitorInitializer>() {{
            put("logs", Builder::addLogMonitor);
            put("screenshot", builder -> builder.addMonitor(new ScreenshotMonitor(new FlutterScreenshotFactory(requestSender))));
            put("environment", Builder::addEnvironmentMonitor);
            put("http", Builder::addHttpMonitor);
            put("location", Builder::addLocationMonitor);
            put("performance", Builder::addPerformanceMonitor);
            put("sqlite", Builder::addSQLMonitor);
            put("shared-preferences", Builder::addSharedPreferenceMonitor);
            put("file-system", Builder::addFileSystemMonitor);
        }};
    }

    private void addMonitors(@NonNull Builder builder, @Nullable List<String> enabledMonitors) {
        if (enabledMonitors == null || enabledMonitors.isEmpty()) {
            builder
                    .withDefaultMonitors()
                    .addMonitor(new ScreenshotMonitor(new FlutterScreenshotFactory(requestSender)));
            return;
        }

        for (String monitor : enabledMonitors) {
            MonitorInitializer initializer = monitorInitializerMap.get(monitor);
            if (initializer != null) {
                initializer.init(builder);
            } else {
                AppspectorLogger.d("Unknown monitor: %s", monitor);
            }
        }
    }

    private void withSharedInstance(@NonNull Result result, @NonNull SharedInstanceAction action) {
        final AppSpector sharedInstance = AppSpector.shared();
        if (sharedInstance != null) {
            result.success(action.run(sharedInstance));
        } else {
            result.error("NotInitialized", "AppSpector shared instance is null", null);
        }
    }

    private static class InternalAppSpectorSessionListener implements SessionUrlListener {

        private final MethodChannel sessionUrlChannel;
        private final Handler handler;

        private InternalAppSpectorSessionListener(@NonNull Handler mainHandler, @NonNull MethodChannel sessionUrlChannel) {
            this.handler = mainHandler;
            this.sessionUrlChannel = sessionUrlChannel;
        }

        @Override
        public void onReceived(@NonNull String sessionUrl) {
            handler.post(() -> sessionUrlChannel.invokeMethod("onSessionUrl", sessionUrl));
        }
    }

    private interface SharedInstanceAction {
        @Nullable
        Object run(@NonNull  AppSpector appSpector);
    }

    private interface MonitorInitializer {
        void init(@NonNull Builder builder);
    }
}
