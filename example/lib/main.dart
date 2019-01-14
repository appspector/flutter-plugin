import 'dart:async';

import 'package:appspector_plugin/appspector_plugin.dart';
import 'package:appspector_plugin_example/color.dart';
import 'package:appspector_plugin_example/http_page.dart';
import 'package:appspector_plugin_example/main_page.dart';
import 'package:appspector_plugin_example/routes.dart';
import 'package:appspector_plugin_example/sqlite_page.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    var config = new Config();
    config.iosApiKey = "YjU1NDVkZGEtN2U3Zi00MDM3LTk5ZGQtNzdkNzY3YmUzZGY2";
    config.androidApiKey = "MWM1YTZlOTItMmU4OS00NGI2LWJiNGQtYjdhZDljNjBhYjcz";
    await AppSpectorPlugin.run(config);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AppSpector plugin sample app',
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
