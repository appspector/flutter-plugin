package com.appspector.flutter.event;

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
    private final Map<String, EventHandler> registeredEvents = new HashMap<>();

    public EventReceiver(MethodChannel eventMethodChannel) {
        eventMethodChannel.setMethodCallHandler(new InternalMethodCallHandler());
        this.methodChannel = eventMethodChannel;
    }

    /**
     * Registration of Sdk Method. In case when sdk method with the same name is already
     * registered at current dispatcher method will throw IllegalStateException
     *
     * @param eventHandler is Sdk Method what should be registered
     */
    public void registerEventHandler(EventHandler eventHandler) {
        if (registeredEvents.containsKey(eventHandler.eventName())) {
            throw new IllegalStateException("Action with same method name (%s) is already registered");
        }
        registeredEvents.put(eventHandler.eventName(), eventHandler);
    }

    private void handleEvent(MethodCall call, MethodChannel.Result result) {
        final EventHandler action = registeredEvents.get(call.method);
        if (action != null) {
            action.handle(call);
            result.success(null);
            return;
        }
        AppspectorLogger.d("Can't find action for method %s", call.method);
        result.notImplemented();
    }

    private class InternalMethodCallHandler implements MethodChannel.MethodCallHandler {

        @Override
        public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
            handleEvent(methodCall, result);
        }
    }
}
