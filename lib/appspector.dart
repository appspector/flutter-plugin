import 'dart:io' show Platform;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

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

  /// Method for starting AppSpector with supplied configs
  static run(Config config) {
    _initCallHandler();

    if (Platform.isAndroid) {
      ArgumentError.checkNotNull(config.androidApiKey, "androidApiKey");
      _initAppSpector(config.androidApiKey);
    } else if (Platform.isIOS) {
      ArgumentError.checkNotNull(config.iosApiKey, "iosApiKey");
      _initAppSpector(config.iosApiKey);
    } else {
      print("AppSpector doesn't support currect platform");
    }
  }

  static _initAppSpector(apiKey) async {
    var configMap = {"apiKey": apiKey};
    await _channel.invokeMethod('run', configMap);
  }

  static _initCallHandler() {
    _channel.setMethodCallHandler(_handler);
  }

  static Future<dynamic> _handler(MethodCall call) async {
    switch (call.method) {
      case "take_screenshot":
        return _takeScreenshot(
            call.arguments["max_width"], call.arguments["quality"]);
      default:
      //todo
    }
  }

  static Future<Uint8List> _takeScreenshot(int maxWidth, int quality) async {
    var renderViewElement =
        WidgetsFlutterBinding.ensureInitialized().renderViewElement;
    var renderObject = renderViewElement.findRenderObject();
    var ratio = maxWidth / renderObject.paintBounds.width;

    var image = await renderObject.layer.toImage(renderObject.paintBounds,
        pixelRatio: ratio > 1.0 ? 1.0 : ratio);

    var byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData.buffer.asUint8List();
  }
}
