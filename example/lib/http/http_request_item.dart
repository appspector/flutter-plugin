import 'app_http_client.dart';

class HttpRequestItems {
  final String title;
  final Future<int> Function(AppHttpClient, String) action;

  HttpRequestItems(this.title, this.action);
}
