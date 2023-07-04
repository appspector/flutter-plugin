import 'package:appspector/appspector.dart' show Logger, AppSpectorPlugin;
import 'package:flutter/material.dart';
import 'package:logging/logging.dart' as logger;

import 'app_drawer.dart';
import 'utils.dart';

class MyHomePage extends StatefulWidget {
  final DataObservable<String> _sessionUrlObserver;

  MyHomePage(this._sessionUrlObserver, {Key? key, required this.title})
      : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState(_sessionUrlObserver);
}

class _MyHomePageState extends State<MyHomePage> {
  final logger.Logger log = new logger.Logger('MyHomePageState');

  int _counter = 0;

  bool isSdkRunning = true;
  late String _sessionUrl;

  _MyHomePageState(DataObservable<String> sessionUrlObserver) {
    sessionUrlObserver.observer = (sessionUrl) => {
          setState(() {
            _sessionUrl = sessionUrl;
          })
        };
    _sessionUrl = sessionUrlObserver.getValue() ?? "Unknown";
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });

    debugPrint("Button IncrementCounter was clicked");
    log.fine("Button IncrementCounter was clicked");
  }

  void _clickLogErrorButton() {
    try {
      _throwError();
    } catch (error, stackTrace) {
      log.finer("TAG _clickLogErrorButton log.finer", error, stackTrace);
      Logger.d("TAG", "_clickLogErrorButton Logger.d", error, stackTrace);
    }
  }

  void _throwError() {
    throw Error();
  }

  void _stopSdk() async {
    await AppSpectorPlugin.shared().stop();
    setState(() {
      isSdkRunning = false;
    });
  }

  void _startSdk() async {
    await AppSpectorPlugin.shared().start();
    setState(() {
      isSdkRunning = true;
    });
  }

  void _checkSdkState() async {
    var isStarted = await AppSpectorPlugin.shared().isStarted();

    setState(() {
      isSdkRunning = isStarted;
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(isStarted ? "SDK is started" : "SDK is stopped"),
    ));
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      drawer: SampleAppDrawer(),
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug paint" (press "p" in the console where you ran
          // "flutter run", or select "Toggle Debug Paint" from the Flutter tool
          // window in IntelliJ) to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(_sessionUrl),
            const SizedBox(height: 124),
            _createSwitchSdkStateButton(),
            const SizedBox(height: 124),
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline3,
            ),
            TextButton(
              child: Text('Click here to log error'),
              onPressed: _clickLogErrorButton,
            ),
            ElevatedButton(
              child: Text('Check SDK state'),
              onPressed: _checkSdkState,
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget _createSwitchSdkStateButton() {
    if (isSdkRunning) {
      return _buildSwitchSdkStateButton("Pause", Colors.redAccent, _stopSdk);
    } else {
      return _buildSwitchSdkStateButton("Resume", Colors.green, _startSdk);
    }
  }

  Widget _buildSwitchSdkStateButton(
      String text, Color color, Function() onPressed) {
    return ButtonTheme(
        minWidth: 120,
        height: 120,
        child: ElevatedButton(
          child: Text(
            text,
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
          ),
          style: ElevatedButton.styleFrom(
            primary: color,
            shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(60),
                side: BorderSide(color: Colors.transparent)),
          ),
          onPressed: onPressed,
        ));
  }
}
