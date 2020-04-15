import 'package:appspector/appspector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appspector_example/metadata_page.dart';
import 'package:flutter_appspector_example/utils.dart';
import 'package:logging/logging.dart' as logger;

import 'color.dart';
import 'http_page.dart';
import 'main_page.dart';
import 'routes.dart';
import 'sqlite_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  var globalSessionUrlObserver = DataObservable<String>();
  runAppSpector(globalSessionUrlObserver);
  runApp(MyApp(globalSessionUrlObserver));

  logger.Logger.root.level = logger.Level.ALL;
  logger.Logger.root.onRecord.listen((logger.LogRecord rec) {
    Logger.log(LogLevel.DEBUG, rec.loggerName, "(${rec.level.name}) ${rec.message}");
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });
}

void runAppSpector(DataObservable<String> sessionObserver) {
  final config = Config()
    ..iosApiKey = "YjU1NDVkZGEtN2U3Zi00MDM3LTk5ZGQtNzdkNzY3YmUzZGY2"
    ..androidApiKey = "MWM1YTZlOTItMmU4OS00NGI2LWJiNGQtYjdhZDljNjBhYjcz"
    ..monitors = [
      Monitors.http,
      Monitors.logs,
      Monitors.screenshot,
      Monitors.environment,
      Monitors.location,
      Monitors.performance,
      Monitors.sqLite,
      Monitors.sharedPreferences,
      Monitors.analytics,
      Monitors.notification,
      Monitors.userDefaults,
      Monitors.coreData
    ]
    ..metadata = {MetadataKeys.deviceName: "CustomName"};

  AppSpectorPlugin.run(config);

  AppSpectorPlugin.shared()?.sessionUrlListener = (sessionUrl) => {
    sessionObserver.setValue(sessionUrl)
  };
}

class MyApp extends StatelessWidget {

 final DataObservable<String> _sessionUrlObserver;

  MyApp(this._sessionUrlObserver);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
          primarySwatch: appSpectorPrimary,
          accentColor: appSpectorAccent),
      home: MyHomePage(_sessionUrlObserver, title: 'Flutter Demo Home Page'),
      routes: {
        Routes.SQLiteMonitorPage: (BuildContext context) => SQLitePage(),
        Routes.HttpMonitorPage: (BuildContext context) => HttpMonitorPage(),
        Routes.MetadataPage: (BuildContext context) => MetadataPage(),
      },
    );
  }
}
