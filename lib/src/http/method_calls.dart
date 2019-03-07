import 'dart:typed_data';

import 'package:appspector/src/method_call.dart';

class TrackHttpResponseMethodCall extends MethodCall {
  final String uid;
  final int timeMs;
  final int code;
  final Map<String, String> headers;
  final String error;
  final Uint8List body;

  TrackHttpResponseMethodCall(
      this.uid, this.timeMs, this.code, this.headers, this.error, this.body);

  @override
  String get name => "trackHttpResponse";

  @override
  Map<String, dynamic> get arguments => {
        "uid": uid,
        "code": code,
        "headers": headers,
        "error": error,
        "body": body,
        "tookMs": timeMs
      };
}

class TrackHttpRequestMethodCall extends MethodCall {
  final String uid;
  final String url;
  final String method;
  final Map<String, String> headers;
  final Uint8List body;

  @override
  String get name => "trackHttpRequest";

  TrackHttpRequestMethodCall(
      this.uid, this.url, this.method, this.headers, this.body);

  @override
  Map<String, dynamic> get arguments => {
        "uid": uid,
        "url": url,
        "method": method,
        "headers": headers,
        "body": body
      };
}
