import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'app_drawer.dart';
import 'http/app_http_client.dart';
import 'http/http_request_item.dart';

class HttpMonitorPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HttpMonitorPageState();
}

class HttpMonitorPageState extends State<HttpMonitorPage> {
  static const _CLIENT_HTTP_LIB = 0;
  static const _CLIENT_IO = 1;
  static const _CLIENT_DIO = 2;

  final _url = "https://google.com";
  final _flutterHttpClient = FlutterHttpClient();
  final _ioHttpClient = IOHttpClient();
  final _dioHttpClient = DioHttpClient();

  final List<HttpRequestItems> requestMethods = [
    new HttpRequestItems("GET Request", (httpClient, url) {
      return httpClient.executeGet(url);
    }),
    new HttpRequestItems("GET Image Request", (httpClient, _) {
      return httpClient.executeGetImage();
    }),
    new HttpRequestItems("POST Request", (httpClient, url) {
      return httpClient.executePost(url);
    }),
    new HttpRequestItems("DELETE Request", (httpClient, url) {
      return httpClient.executeDelete(url);
    }),
    new HttpRequestItems("PUT Request", (httpClient, url) {
      return httpClient.executePut(url);
    }),
    new HttpRequestItems("PATCH Request", (httpClient, url) {
      return httpClient.executePatch(url);
    }),
    new HttpRequestItems("HEAD Request", (httpClient, url) {
      return httpClient.executeHead(url);
    }),
    new HttpRequestItems("TRACE Request", (httpClient, url) {
      return httpClient.executeTrace(url);
    }),
    new HttpRequestItems("OPTIONS Request", (httpClient, url) {
      return httpClient.executeOptions(url);
    })
  ];

  int _selectedClient = _CLIENT_HTTP_LIB;
  int? _statusCode;
  String? _error;
  int? _requestDuration;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("HTTP Monitor"),
      ),
      drawer: SampleAppDrawer(),
      body: SingleChildScrollView(
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0),
              child: Column(children: <Widget>[
                const Text(
                    "Choose HTTP client:",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        height: 2
                    )
                ),
                Row(children: <Widget>[
                  Expanded(
                      child: RadioListTile(
                          value: _CLIENT_HTTP_LIB,
                          groupValue: _selectedClient,
                          title: const Text("HTTP Lib"),
                          onChanged: _onClientSelectChanged)
                  ),
                  Expanded(child: RadioListTile(
                      value: _CLIENT_IO,
                      title: const Text("IO"),
                      groupValue: _selectedClient,
                      onChanged: _onClientSelectChanged)
                  ),
                  Expanded(child: RadioListTile(
                      value: _CLIENT_DIO,
                      title: const Text("DIO"),
                      groupValue: _selectedClient,
                      onChanged: _onClientSelectChanged)
                  )
                ]),
                Container(
                    margin: EdgeInsets.only(top: 24.0),
                    child: Text.rich(TextSpan(children: _createResultedText()))
                ),
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  primary: false,
                  childAspectRatio: 3,
                  children: createRequestMethodWidgetList(),
                )
              ])
          )
      ),
    );
  }

  List<Widget> createRequestMethodWidgetList() {
    return requestMethods.map((item) {
      return Container(
          alignment: Alignment.center,
//          margin: EdgeInsets.only(top: 24.0),
          child: RaisedButton(
              child: Text(item.title),
              onPressed: () {
                Stopwatch stopwatch = Stopwatch()..start();
                item.action(_provideClient(), _url).then((responseCode) {
                  _onHttpResponse(responseCode, stopwatch.elapsedMilliseconds);
                }).onError(
                    (error, stackTrace) => _onHttpError(error as Exception, stopwatch.elapsedMilliseconds));
              }));
    }).toList();
  }

  AppHttpClient _provideClient() {
    switch (_selectedClient) {
      case _CLIENT_HTTP_LIB: return _flutterHttpClient;
      case _CLIENT_IO: return _ioHttpClient;
      case _CLIENT_DIO: return _dioHttpClient;
    }
    throw Exception("Unknown client id");
  }

  _onHttpResponse(int statusCode, int requestDuration) {
    setState(() {
      _statusCode = statusCode;
      _requestDuration = requestDuration;
      _error = null;
    });
  }

  _onHttpError(Exception e, int requestDuration) {
    setState(() {
      _statusCode = null;
      _requestDuration = requestDuration;
      _error = e is DioError ? e.message + " (" + requestDuration.toString() + " ms)" : e.toString();
    });
  }

  List<TextSpan> _createResultedText() {
    if (_error != null) {
      return [TextSpan(text: _error)];
    }
    if (_statusCode != null) {
      List<TextSpan> lines = [];
      lines.add(TextSpan(text: "Request finished with code: $_statusCode \n\n"));
      lines.add(TextSpan(text: "$_requestDuration ms"));
      return lines;
    }
    return [TextSpan(text: "Click any button")];
  }

  _onClientSelectChanged(int? newValue) {
    setState(() {
      _selectedClient = newValue ?? _CLIENT_HTTP_LIB;
    });
  }
}
