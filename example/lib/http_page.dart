import 'package:flutter/material.dart';
import 'app_drawer.dart';
import 'package:http/http.dart' as http;

class HttpMonitorPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HttpMonitorPageState();
}

class HttpMonitorPageState extends State<HttpMonitorPage> {

  final _url = "https://google.com";
  int _statusCode;
  int _requestDuration;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("SQLite Monitor"),
        ),
        drawer: SampleAppDrawer(),
        body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              children: <Widget>[
                Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(top: 24.0),
                    child: RaisedButton(
                        child: Text("Execute HTTP Request"),
                        onPressed: _executeHttpRequest)),
                Container(
                  margin: EdgeInsets.only(top: 24.0),
                  child: Text(_statusCode == null ? "" : "Request finished with code: $_statusCode"),
                ),
                Container(
                  margin: EdgeInsets.only(top: 24.0),
                  child: Text(_requestDuration == null ? "" : "$_requestDuration ms"),
                )
              ],
            )));
  }

  _executeHttpRequest() {
    debugPrint("Executing HTTP request");
    Stopwatch stopwatch = Stopwatch()..start();
    http.get(_url).then((result) {
      _onHttpResponse(result, stopwatch.elapsedMilliseconds);
      stopwatch.stop();
    });
  }

  _onHttpResponse(http.Response result, int requestDuration) {
    setState(() {
      _statusCode = result.statusCode;
      _requestDuration = requestDuration;
    });
  }
}
