import 'dart:async';

import 'package:flutter/services.dart';

class AppSpectorPlugin {
  static const MethodChannel _channel =
      const MethodChannel('appspector_plugin');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<void> run(Map<String, Object> configs) async {
    await _channel.invokeMethod('run', configs);
  }
}
