import 'package:flutter/services.dart' show MethodChannel;

class EventSender {
  static const MethodChannel _channel =
      const MethodChannel('appspector_event_channel');

  static sendEvent(Event event) async {
    await _channel.invokeMethod(event.name, event.arguments);
  }
}

abstract class Event {
  String get name;

  Map<String, dynamic> get arguments;
}
