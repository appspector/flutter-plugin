import 'dart:io' show HttpHeaders;
import 'dart:typed_data' show Uint8List;

import 'package:appspector/src/event_sender.dart' show EventSender;
import 'package:appspector/src/http/events.dart';

class HttpEventTracker {
  final String _url;
  final String _uid;
  final String _method;
  final int _startTime;
  Uint8List? data;

  HttpEventTracker.fromUri(this._method, this._uid, Uri uri)
      : this._url = uri.toString(),
        this._startTime = DateTime.now().millisecondsSinceEpoch;

  HttpEventTracker.fromHost(
      this._method, this._uid, String host, int port, String path)
      : this._url =
            Uri(scheme: "http", host: host, port: port, path: path).toString(),
        this._startTime = DateTime.now().millisecondsSinceEpoch;

  void onError(Exception e) {
    _sendRequestEvent({});

    EventSender.sendEvent(new HttpResponseEvent(
        _uid, _calcDurationTime(), 0, {}, e.toString(), null));
  }

  void addData(List<int> bytes) {
    this.data = Uint8List.fromList(bytes);
  }

  void sendRequestEvent(HttpHeaders headers) =>
      _sendRequestEvent(_headersToMap(headers));

  void _sendRequestEvent(Map<String, String> headers) {
    EventSender.sendEvent(
        new HttpRequestEvent(_uid, _url, _method, headers, data));
  }

  void sendSuccessResponse(
      int statusCode, HttpHeaders headers, List<int> data) {
    EventSender.sendEvent(new HttpResponseEvent(_uid, _calcDurationTime(),
        statusCode, _headersToMap(headers), null, Uint8List.fromList(data)));
  }

  int _calcDurationTime() {
    return DateTime.now().millisecondsSinceEpoch - _startTime;
  }

  Map<String, String> _headersToMap(HttpHeaders httpHeaders) {
    final Map<String, String> headers = {};

    httpHeaders.forEach((header, values) {
      headers[header] = values.first;
    });

    return headers;
  }
}
