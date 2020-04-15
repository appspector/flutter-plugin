[![GitHub release](https://img.shields.io/github/release/appspector/flutter-plugin.svg)](https://github.com/appspector/flutter-plugin)
# ![AppSpector](https://github.com/appspector/flutter-plugin/raw/master/github-cover.png)

A plugin that integrate [AppSpector](https://appspector.com/?utm_source=flutter_readme) to your Flutter project.

With AppSpector you can remotely debug your app running in the same room or on another continent. 
You can measure app performance, view database content, logs, network requests and many more in realtime. 
This is the instrument that you've been looking for. Don't limit yourself only to simple logs. 
Debugging doesn't have to be painful!

<img src="https://github.com/appspector/appspector-flutter/raw/master/static/appspector_demo.gif" width="700px" alt="AppSpector demonstration" />

* [Installation](#installation)
  * [Add AppSpector plugin to pubspec.yaml](#add-appspector-plugin-to-pubspecyaml)
  * [Initialize AppSpector plugin](#initialize-appspector-plugin)
  * [Build and Run](#build-and-run)
* [Configure](#configure)
  * [Start/Stop data collection](#startstop-data-collection)
  * [Custom device name](#custom-device-name)
* [Features](#features)
  * [SQLite monitor](#sqlite-monitor)
  * [HTTP monitor](#http-monitor)
  * [Logs monitor](#logs-monitor)
    * [Logger](#logger)
  * [Location monitor](#location-monitor)
  * [Screenshot monitor](#screenshot-monitor)
  * [SharedPreference/UserDefaults monitor](#sharedpreferenceuserdefaults-monitor)
  * [Performance monitor](#performance-monitor)
  * [Environment monitor](#environment-monitor)
  * [Notification Center monitor (only for iOS)](#notification-center-monitor-only-for-ios)
* [Feedback](#feedback)


# Installation

Each app you want to use with AppSpector SDK you have to register iOS and
Android app versions on our service through the web ([https://app.appspector.com](https://app.appspector.com?utm_source=android_readme))
or the [desktop app](https://appspector.com/download/?utm_source=android_readme).
After adding the application API keys will be available on the app settings pages.

## Add AppSpector plugin to pubspec.yaml
```yaml
dependencies
  appspector: '0.2.0'
```

## Initialize AppSpector plugin
```dart
import 'package:appspector/appspector.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runAppSpector();
  runApp(MyApp());
}

void runAppSpector() {
  var config = new Config()
    ..iosApiKey = "Your iOS API_KEY"
    ..androidApiKey = "Your Android API_KEY";
  
  // If you don't want to start all monitors you can provide list of them
  config.monitors = [Monitors.http, Monitors.logs, Monitors.screenshot];
  
  AppSpectorPlugin.run(config);
}
```

## Build and Run
Build your project and see everything work! When your app is up and running you can go to [https://app.appspector.com](https://app.appspector.com/?utm_source=flutter_readme) and connect to your application session.


# Configure

## Start/Stop data collection

After calling the `run` method the SDKs start data collection and
data transferring to the web service. From that point you can see
your session in the AppSpector client.

Since plugin initialization should locate in the main function we provide
methods to help you control AppSpector state by calling `stop()` and `start()` methods.

**You are able to use these methods only after AppSpector was initialized.**

The `stop()` tells AppSpector to disable all data collection and close current session.

```dart
await AppSpectorPlugin.shared().stop();
```

The `start()` starts it again using config you provided at initialization.

```dart
await AppSpectorPlugin.shared().start();
```

**As the result new session will be created and all activity between
`stop()` and `start()` calls will not be tracked.**

To check AppSpector state you can use `isStarted()` method.

```dart
await AppSpectorPlugin.shared().isStarted();
```

## Custom device name

You can assign a custom name to your device to easily find needed sessions
in the sessions list. To do this you should add the desired name as a value
for `MetadataKeys.deviceName` key to the `metadata` dictionary:

```dart
void runAppSpector() {
  var config = new Config()
    ..iosApiKey = "Your iOS API_KEY"
    ..androidApiKey = "Your Android API_KEY"
    ..metadata = {MetadataKeys.deviceName: "CustomName"};
  
  AppSpectorPlugin.run(config);
}
```

Also, the plugin allows managing the device name during application lifetime using

the `setMetadataValue` method to change device name

```dart
AppSpectorPlugin.shared().setMetadataValue(MetadataKeys.deviceName, "New Device Name");
```

or the `removeMetadataValue` to remove your custom device name

```dart
AppSpectorPlugin.shared().removeMetadataValue(MetadataKeys.deviceName);
```


# Features

AppSpector provides many monitors that are can be different for both platforms.

### SQLite monitor
Provides browser for sqlite databases found in your app. Allows to track all queries, shows DB scheme and data in DB. You can issue custom SQL query on any DB and see results in browser immediately.

<img src="https://storage.googleapis.com/appspector.com/images/monitor-screenshots/sqlite-monitor@2x.png" width="700px" alt="SQLite monitor" />

#### HTTP monitor
Shows all HTTP traffic in your app. You can examine any request, see request/response headers and body.
We provide XML and JSON highliting for request/responses with formatting and folding options so even huge responses are easy to look through.

<img src="https://storage.googleapis.com/appspector.com/images/monitor-screenshots/network-monitor@2x.png" width="700px" alt="HTTP monitor" />

### Logs monitor
Displays all logs generated by your app.

#### Logger
AppSpector Logger allows you to collect log message only into AppSpector service.

<img src="https://storage.googleapis.com/appspector.com/images/monitor-screenshots/logs-monitor@2x.png" width="700px" alt="Logs" />

### Location monitor
Most of the apps are location-aware. Testing it requires changing locations yourself. In this case, location mocking is a real time saver. Just point to the location on the map and your app will change its geodata right away.

<img src="https://storage.googleapis.com/appspector.com/images/monitor-screenshots/location-monitor@2x.png" width="700px" alt="Location" />

### Screenshot monitor
Simply captures screenshot from the device.

### SharedPreference/UserDefaults monitor
Provides browser and editor for SharedPreferences/UserDefaults.

### Performance monitor
Displays real-time graphs of the CPU / Memory/ Network / Disk / Battery usage.

### Environment monitor
Gathers all of the environment variables and arguments in one place, info.plist, cli arguments and much more.

### Notification Center monitor (only for iOS)
Tracks all posted notifications and subscriptions. You can examine notification user info, sender/reciever objects, etc.
And naturally you can post notifications to your app from the frontend.


For mode details, you can visit [Android SDK](https://github.com/appspector/android-sdk/) and [iOS SDK](https://github.com/appspector/ios-sdk) pages.


# Feedback
Let us know what do you think or what would you like to be improved: [info@appspector.com](mailto:info@appspector.com).

[Join our slack to discuss setup process and features](https://slack.appspector.com)
