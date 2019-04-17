package com.appspector.flutter.event;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

/**
 * Abstract EventHandler to handle calls from AppSpector Flutter SDK
 */
public abstract class EventHandler {

    /**
     * Event identifier what is used in Flutter part of SDK
     *
     * @return event name. Cannot be null
     */
    public abstract String eventName();

    /**
     * Method for handling received event
     *
     * @param call   contains method name and arguments
     */
    public abstract void handle(MethodCall call);
}
