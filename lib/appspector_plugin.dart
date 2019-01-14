import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';

class Config {
  String iosApiKey;
  String androidApiKey;
}

class AppSpectorPlugin {
  static const MethodChannel _channel =
      const MethodChannel('appspector_plugin');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<void> run(Config config) async {
    var key = "";

    if (Platform.isAndroid) {
      key = config.androidApiKey;
    } else if (Platform.isIOS) {
      key = config.iosApiKey;
    }

    Map<String, Object> configMap = {
      "apiKey": key,
      "debugLogging": true
    };
    await _channel.invokeMethod('run', configMap);
  }
}
