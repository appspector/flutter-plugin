# appspector_plugin

A plugin that integrate AppSpector to Flutter project.

With AppSpector you can remotely debug your app running in the same room or on another continent. 
You can measure app performance, view database content, logs, network requests and many more in realtime. 
This is the instrument that you've been looking for. Don't limit yourself only to simple logs. 
Debugging doesn't have to be painful!

# Installation

Each app you want to use with AppSpector SDK you have to register on the web (https://app.appspector.com)
and add two native applications(for iOS and Android). Application API keys will be available on 
the app settings page.

## Add AppSpector SDK to pubspec.yaml
```yaml
dependencies:
  appspector_plugin: '0.0.1'
```

## Initialize AppSpector SDK
```dart
void main() {
  runAppSpector();
  runApp(MyApp());
}

Future<void> runAppSpector() async {
  var config = new Config();
  config.iosApiKey = "Your iOS API_KEY";
  config.androidApiKey = "Your Android API_KEY";
  await AppSpectorPlugin.run(config);
}
```

## Build and Run
Build your project and see everything work! When your app is up and running you can go 
to https://app.appspector.com and connect to your application session.

# Features

AppSpector provides many monitors that are can be different for both platforms.
For mode details, you can visit [AppSpector SDK](https://github.com/appspector/android-sdk/) and [iOS SDK](https://github.com/appspector/ios-sdk) pages.
