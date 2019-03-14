package com.appspector.flutter.event;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

/**
 * Abstract Event to handle calls from AppSpector Flutter SDK
 */
public abstract class Event {

    /**
     * Event name what uses in Flutter part of SDK
     *
     * @return event name. Cannot be null
     */
    public abstract String eventName();

    /**
     * Method for dispatching invocation to registered method
     *
     * @param call   contains method name and arguments
     */
    public abstract void track(MethodCall call);
}
