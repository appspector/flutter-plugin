package com.appspector.flutter.event;

import android.util.Log;

import com.appspector.sdk.core.util.AppspectorLogger;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

/**
 * EventReceiver is locator of a sdk methods. It chooses the method by name from registered ones
 * and execute invocation on it.
 */
public final class EventReceiver {

    @SuppressWarnings({"FieldCanBeLocal", "unused"})
    private final MethodChannel methodChannel;
    private final Map<String, Event> registeredEvents = new HashMap<>();

    public EventReceiver(MethodChannel eventMethodChannel) {
        eventMethodChannel.setMethodCallHandler(new EventHandler());
        this.methodChannel = eventMethodChannel;
    }

    /**
     * Registration of Sdk Method. In case when sdk method with the same name is already
     * registered at current dispatcher method will throw IllegalStateException
     *
     * @param event is Sdk Method what should be registered
     */
    public void registerEvent(Event event) {
        if (registeredEvents.containsKey(event.eventName())) {
            throw new IllegalStateException("Action with same method name (%s) is already registered");
        }
        registeredEvents.put(event.eventName(), event);
    }

    private void handleEvent(MethodCall call, MethodChannel.Result result) {
        final Event action = registeredEvents.get(call.method);
        if (action != null) {
            action.track(call);
            result.success(null);
            return;
        }
        AppspectorLogger.d("Can't find action for method %s", call.method);
        result.notImplemented();
    }

    private class EventHandler implements MethodChannel.MethodCallHandler {

        @Override
        public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
            handleEvent(methodCall, result);
        }
    }
}
