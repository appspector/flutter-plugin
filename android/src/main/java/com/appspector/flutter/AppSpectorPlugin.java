package com.appspector.flutter;

import android.app.Application;

import com.appspector.flutter.event.EventReceiver;
import com.appspector.flutter.event.http.HttpRequestEventHandler;
import com.appspector.flutter.event.http.HttpResponseEventHandler;
import com.appspector.flutter.event.log.LogEventHandler;
import com.appspector.flutter.screenshot.FlutterScreenshotFactory;
import com.appspector.sdk.AppSpector;
import com.appspector.sdk.monitors.screenshot.ScreenshotMonitor;

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
    @SuppressWarnings("unchecked")
    public void onMethodCall(MethodCall call, Result result) {
        switch (call.method) {
            case "run":
                initAppSpector((String) call.argument("apiKey"));
                result.success(null);
                break;
            default:
                result.notImplemented();
        }
    }

    private void initAppSpector(String apiKey) {
        AppSpector.build(application)
                .withDefaultMonitors()
                .addMonitor(new ScreenshotMonitor(new FlutterScreenshotFactory(requestSender)))
                .run(apiKey);
    }
}
