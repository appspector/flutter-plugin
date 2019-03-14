import 'dart:io' show Platform, HttpOverrides;

import 'package:appspector/src/http/http_overrides.dart';
import 'package:appspector/src/request_receiver.dart';
import 'package:flutter/services.dart' show MethodChannel;

/// This class needed to aggregate AppSpector properties and arguments.
class Config {
  /// API_KEY of your iOS Application.
  ///
  /// Property is optional if your app don't support iOS.
  /// Your can find API_KEY on settings page of you Application
  ///
  /// If you don't specify it and try to launch your app on iOS
  /// SDK will throw ArgumentError
  String iosApiKey;

  /// API_KEY of your Android Application.
  ///
  /// Property is optional if your app don't support Android.
  /// Your can find API_KEY on settings page of you Application
  ///
  /// If you don't specify it and try to launch your app on Android
  /// SDK will throw ArgumentError
  String androidApiKey;
}

/// This is the main class for using AppSpector. AppSpector captures various
/// types of data to assist in debugging, analyzing application state and
/// understanding user behavior.
/// <p>
/// <p>Here is an example of how AppSpector is used:
/// <pre>
/// void main() {
///   runAppSpector();
///   runApp(MyApp());
/// }
///
/// void runAppSpector() {
///   var config = new Config();
///   config.iosApiKey = "Your iOS API_KEY";
///   config.androidApiKey = "Your Android API_KEY";
///   AppSpectorPlugin.run(config);
/// }
/// </pre></p>
/// <p>For more information visit the <a href="https://docs.appspector.com">AppSpector Page</a>.</p>
class AppSpectorPlugin {
  static const MethodChannel _channel =
      const MethodChannel('appspector_plugin');
  static final RequestReceiver _requestReceiver = new RequestReceiver();

  /// Method for starting AppSpector with supplied configs
  static Future<dynamic> run(Config config) {
    HttpOverrides.global = AppSpectorHttpOverrides();
    _requestReceiver.observeChannel();

    if (Platform.isAndroid) {
      ArgumentError.checkNotNull(config.androidApiKey, "androidApiKey");
      return _initAppSpector(config.androidApiKey);
    } else if (Platform.isIOS) {
      ArgumentError.checkNotNull(config.iosApiKey, "iosApiKey");
      return _initAppSpector(config.iosApiKey);
    } else {
      return Future.error("AppSpector doesn't support currect platform");
    }
  }

  static _initAppSpector(String apiKey) =>
      _channel.invokeMethod("run", {"apiKey": apiKey});
}
