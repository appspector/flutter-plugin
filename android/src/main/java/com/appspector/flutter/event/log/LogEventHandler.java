package com.appspector.flutter.event.log;

import com.appspector.flutter.event.EventHandler;
import com.appspector.sdk.monitors.log.Logger;

import java.util.Map;

import io.flutter.plugin.common.MethodCall;

public class LogEventHandler extends EventHandler {

    @Override
    public String eventName() {
        return "log-event";
    }

    @Override
    @SuppressWarnings({"unchecked", "ConstantConditions"})
    public void handle(MethodCall call) {
        Map<String, Object> args = (Map<String, Object>) call.arguments;
        Logger.log(
                (Integer) args.get("level"),
                (String) args.get("tag"),
                (String) args.get("message")
        );
    }
}
