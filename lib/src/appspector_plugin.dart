import 'dart:io' show Platform, HttpOverrides;

import 'package:appspector/src/http/http_overrides.dart';
import 'package:appspector/src/monitors.dart';
import 'package:appspector/src/request_receiver.dart';
import 'package:flutter/services.dart' show MethodCall, MethodChannel;

/// This class needed to aggregate AppSpector properties and arguments.
class Config {
  /// API_KEY of your iOS Application.
  ///
  /// Property is optional if your app don't support iOS.
  /// Your can find API_KEY on settings page of your Application
  ///
  /// If you don't specify it and try to launch the app on iOS
  /// SDK will throw ArgumentError
  String iosApiKey;

  /// API_KEY of your Android Application.
  ///
  /// Property is optional if your app don't support Android.
  /// Your can find API_KEY on settings page of your Application
  ///
  /// If you don't specify it and try to launch the app on Android
  /// SDK will throw ArgumentError
  String androidApiKey;

  /// Collection of metadata information
  ///
  /// Property is optional. It allows to attach some additional
  /// information to session. For example, you can specify device name by
  /// putting it with MetaDataKeys.deviceName key
  Map<String, String> metadata;

  /// List of monitor which will be enabled
  ///
  /// Property is optional. By default all available monitors will be enabled.
  /// E.g. to enable necessary monitors you need to provide list
  /// like [Monitors.http, Monitors.screenshot]
  List<Monitor> monitors;
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
  static AppSpectorPlugin _appSpectorPlugin;

  final MethodChannel _channel = const MethodChannel('appspector_plugin');
  final RequestReceiver _requestReceiver = new RequestReceiver();

  Function(String) sessionUrlListener;

  AppSpectorPlugin._withConfig(Config config) {
    HttpOverrides.global = AppSpectorHttpOverrides();
    _requestReceiver.observeChannel();
    _channel.setMethodCallHandler(_handlePluginCalls);
    _appSpectorPlugin = this;
  }

  Future<dynamic> _init(Config config) {
    final monitors = config.monitors ?? Monitors.all();
    if (Platform.isAndroid) {
      ArgumentError.checkNotNull(config.androidApiKey, "androidApiKey");
      return _initAppSpector(
          config.androidApiKey,
          _filterByPlatform(monitors, SupportedPlatform.android),
          config.metadata);
    } else if (Platform.isIOS) {
      ArgumentError.checkNotNull(config.iosApiKey, "iosApiKey");
      return _initAppSpector(config.iosApiKey,
          _filterByPlatform(monitors, SupportedPlatform.ios), config.metadata);
    } else {
      return Future.error("AppSpector doesn't support current platform");
    }
  }

  Future<dynamic> _handlePluginCalls(MethodCall methodCall) async {
    if (methodCall.method == "onSessionUrl") {
      if (sessionUrlListener != null) {
        sessionUrlListener(methodCall.arguments);
      }
    }
  }

  /// Returns shared instance of SDK plugin
  static AppSpectorPlugin shared() => _appSpectorPlugin;

  /// Method for starting AppSpector with supplied configs
  static Future<dynamic> run(Config config) {
    return new AppSpectorPlugin._withConfig(config)._init(config);
  }

  _initAppSpector(String apiKey, Iterable<Monitor> monitors,
          Map<String, String> metadata) =>
      _channel.invokeMethod("run", {
        "apiKey": apiKey,
        "enabledMonitors": monitors.map((m) => m.id).toList(),
        "metadata": metadata
      });

  /// Stop all monitors and events sending
  Future<void> stop() => _channel.invokeMethod("stop");

  /// Resume sending events and work of all monitors
  Future<void> start() => _channel.invokeMethod("start");

  /// Returns true if sdk is started
  Future<bool> isStarted() => _channel.invokeMethod("isStarted");

  /// Set metadata value
  Future<void> setMetadataValue(String key, String value) =>
      _channel.invokeMethod("setMetadata", {"key": key, "value": value});

  /// Remove metadata value
  Future<void> removeMetadataValue(String key) =>
      _channel.invokeMethod("removeMetadata", {"key": key});

  Iterable<Monitor> _filterByPlatform(
      List<Monitor> monitors, SupportedPlatform platform) {
    return monitors.where((m) => m.platforms.contains(platform));
  }
}

/// Identifiers for supported metadata keys
/// Sdk provides opportunity to send additional session information
///
/// For more information see Config.metadata method
class MetadataKeys {
  MetadataKeys._();

  /// Supported key to change device name
  static const deviceName = "userSpecifiedDeviceName";
}
