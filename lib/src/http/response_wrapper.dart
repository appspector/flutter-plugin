import 'dart:async' show StreamView;
import 'dart:io';
import 'dart:typed_data';

class HttpResponseWrapper extends StreamView<List<int>>
    implements HttpClientResponse {
  final HttpClientResponse _httpClientResponse;

  HttpResponseWrapper(this._httpClientResponse, Stream<Uint8List> stream)
      : super(stream);

  @override
  X509Certificate get certificate => _httpClientResponse.certificate;

  @override
  HttpConnectionInfo get connectionInfo => _httpClientResponse.connectionInfo;

  @override
  int get contentLength => _httpClientResponse.contentLength;

  @override
  List<Cookie> get cookies => _httpClientResponse.cookies;

  @override
  Future<Socket> detachSocket() => _httpClientResponse.detachSocket();

  @override
  HttpHeaders get headers => _httpClientResponse.headers;

  @override
  bool get isRedirect => _httpClientResponse.isRedirect;

  @override
  bool get persistentConnection => _httpClientResponse.persistentConnection;

  @override
  String get reasonPhrase => _httpClientResponse.reasonPhrase;

  @override
  Future<HttpClientResponse> redirect(
      [String method, Uri url, bool followLoops]) {
    return _httpClientResponse.redirect(method, url, followLoops);
  }

  @override
  List<RedirectInfo> get redirects => _httpClientResponse.redirects;

  @override
  int get statusCode => _httpClientResponse.statusCode;

  @override
  HttpClientResponseCompressionState get compressionState =>
      _httpClientResponse.compressionState;
}
