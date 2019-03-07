import 'dart:async' show Future;
import 'dart:io';

import 'package:appspector/src/http/request_wrapper.dart';
import 'package:appspector/src/http/tracker.dart';

class AppSpectorHttpClient implements HttpClient {
  final HttpClient _httpClient;
  final String Function() _uidGenerator;

  AppSpectorHttpClient(this._httpClient, this._uidGenerator);

  @override
  bool autoUncompress;

  @override
  Duration connectionTimeout;

  @override
  Duration idleTimeout;

  @override
  int maxConnectionsPerHost;

  @override
  String userAgent;

  @override
  void addCredentials(
      Uri url, String realm, HttpClientCredentials credentials) {
    return _httpClient.addCredentials(url, realm, credentials);
  }

  @override
  void addProxyCredentials(
      String host, int port, String realm, HttpClientCredentials credentials) {
    return _httpClient.addProxyCredentials(host, port, realm, credentials);
  }

  @override
  set authenticate(
      Future<bool> Function(Uri url, String scheme, String realm) f) {
    _httpClient.authenticate = f;
  }

  @override
  set authenticateProxy(
      Future<bool> Function(String host, int port, String scheme, String realm)
          f) {
    _httpClient.authenticateProxy = f;
  }

  @override
  set badCertificateCallback(
      bool Function(X509Certificate cert, String host, int port) callback) {
    _httpClient.badCertificateCallback = callback;
  }

  @override
  set findProxy(String Function(Uri url) f) {
    _httpClient.findProxy = f;
  }

  @override
  void close({bool force = false}) {
    return _httpClient.close(force: force);
  }

  @override
  Future<HttpClientRequest> delete(String host, int port, String path) =>
      open("delete", host, port, path);

  @override
  Future<HttpClientRequest> deleteUrl(Uri url) => openUrl("delete", url);

  @override
  Future<HttpClientRequest> get(String host, int port, String path) =>
      open("get", host, port, path);

  @override
  Future<HttpClientRequest> getUrl(Uri url) => openUrl("get", url);

  @override
  Future<HttpClientRequest> head(String host, int port, String path) =>
      open("head", host, port, path);

  @override
  Future<HttpClientRequest> headUrl(Uri url) => openUrl("head", url);

  @override
  Future<HttpClientRequest> patch(String host, int port, String path) =>
      open("patch", host, port, path);

  @override
  Future<HttpClientRequest> patchUrl(Uri url) => openUrl("patch", url);

  @override
  Future<HttpClientRequest> post(String host, int port, String path) =>
      open("post", host, port, path);

  @override
  Future<HttpClientRequest> postUrl(Uri url) => openUrl("post", url);

  @override
  Future<HttpClientRequest> put(String host, int port, String path) =>
      open("put", host, port, path);

  @override
  Future<HttpClientRequest> putUrl(Uri url) => openUrl("put", url);

  @override
  Future<HttpClientRequest> open(
      String method, String host, int port, String path) {
    final tracker = HttpEventTracker.fromHost(
        method, _uidGenerator(), host, port, path);
    return _httpClient.open(method, host, port, path).then((request) {
      return HttpRequestWrapper(request, tracker);
    }).catchError((e) {
      tracker.onError(e);
    });
  }

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async {
    final tracker = HttpEventTracker.fromUri(method, _uidGenerator(), url);
    return _httpClient.openUrl(method, url).then((request) {
      return HttpRequestWrapper(request, tracker);
    }).catchError((e) {
      tracker.onError(e);
    });
  }
}
