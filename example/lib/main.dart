import 'package:appspector/appspector.dart';
import 'package:flutter/material.dart';

import 'color.dart';
import 'http_page.dart';
import 'main_page.dart';
import 'routes.dart';
import 'sqlite_page.dart';

void main() {
  runAppSpector();
  runApp(MyApp());
}

void runAppSpector() {
  var config = new Config();
  config.iosApiKey = "YjU1NDVkZGEtN2U3Zi00MDM3LTk5ZGQtNzdkNzY3YmUzZGY2";
  config.androidApiKey = "MWM1YTZlOTItMmU4OS00NGI2LWJiNGQtYjdhZDljNjBhYjcz";
  AppSpectorPlugin.run(config);
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
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
      home: MyHomePage(title: 'Flutter Demo Home Page'),
      routes: {
        Routes.SQLiteMonitorPage: (BuildContext context) => SQLitePage(),
        Routes.HttpMonitorPage: (BuildContext context) => HttpMonitorPage(),
      },
    );
  }
}
