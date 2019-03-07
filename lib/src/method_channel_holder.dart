import 'dart:async';

import 'package:appspector/src/method_call.dart' ;
import 'package:flutter/services.dart' as services;

class MethodChannelHolder {
  static const services.MethodChannel _channel =
  const services.MethodChannel('appspector_plugin');

  static invokeMethod(MethodCall methodCall) async {
    await _channel.invokeMethod(methodCall.name, methodCall.arguments);
  }

  static setMethodCallHandler(
      Future<dynamic> handler(services.MethodCall call)) {
    _channel.setMethodCallHandler(handler);
  }
}
