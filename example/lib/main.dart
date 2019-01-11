import 'dart:async';

import 'package:appspector_plugin/appspector_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    Map<String, String> configs = {
      "androidApiKey": "MWM1YTZlOTItMmU4OS00NGI2LWJiNGQtYjdhZDljNjBhYjcz",
      "iosApiKey": "YjU1NDVkZGEtN2U3Zi00MDM3LTk5ZGQtNzdkNzY3YmUzZGY2",
    };
    await AppSpectorPlugin.init(configs);

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('AppSpector plugin sample app'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }
}
