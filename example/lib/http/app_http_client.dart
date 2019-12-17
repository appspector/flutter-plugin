import 'dart:convert';
import 'dart:io' show HttpClient, HttpClientRequest, HttpHeaders;

import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

abstract class AppHttpClient {
  Future<int> executeGet(String url);

  Future<int> executeGetImage();

  Future<int> executePost(String url);

  Future<int> executeDelete(String url);

  Future<int> executePut(String url);

  Future<int> executePatch(String url);

  Future<int> executeHead(String url);

  Future<int> executeTrace(String url);

  Future<int> executeOptions(String url);
}

class FlutterHttpClient extends AppHttpClient {
  @override
  Future<int> executeDelete(String url) {
    return http.delete(url).then((response) {
      return response.statusCode;
    });
  }

  @override
  Future<int> executeGet(String url) {
    return http.get(url).then((response) {
      return response.statusCode;
    });
  }

  @override
  Future<int> executeGetImage() {
    return http
        .get(
            "https://raw.githubusercontent.com/appspector/android-sdk/master/images/github-cover.png")
        .then((response) {
      return response.statusCode;
    });
  }

  @override
  Future<int> executeHead(String url) {
    return http.head(url).then((response) {
      return response.statusCode;
    });
  }

  @override
  Future<int> executeOptions(String url) {
    throw Exception("OPTION request is not supported by current client");
  }

  @override
  Future<int> executePatch(String url) async {
    final body = await rootBundle.loadString("assets/patch.json");
    return http.patch(url, body: body).then((response) {
      return response.statusCode;
    });
  }

  @override
  Future<int> executePost(String url) async {
//    final body = await rootBundle.loadString("assets/post.json");
    final data = """{
      "eventId": 1,
      "companyId": 201,
      "jobRoleId": "3",
      "expressBadge": false,
      "fcmToken": "svsdfvdsvf"
    }""";
    final headers = {"Content-Type": "application/json; charset=utf-8"};
    return http.post(url, headers: headers, body: data).then((response) {
      return response.statusCode;
    });
  }

  @override
  Future<int> executePut(String url) async {
    final body = await rootBundle.loadString("assets/put.json");
    return http.put(url, body: body).then((response) {
      return response.statusCode;
    });
  }

  @override
  Future<int> executeTrace(String url) {
    throw Exception("TRACE request is not supported by current client");
  }
}

class IOHttpClient extends AppHttpClient {
  final client = HttpClient();

  @override
  Future<int> executeDelete(String url) {
    return _executeRequest(client.deleteUrl(Uri.parse(url)));
  }

  @override
  Future<int> executeGet(String url) {
    return _executeRequest(client.getUrl(Uri.parse(url)));
  }

  @override
  Future<int> executeGetImage() {
    return _executeRequest(client.getUrl(Uri.parse(
        "https://raw.githubusercontent.com/appspector/android-sdk/master/images/github-cover.png")));
  }

  @override
  Future<int> executeHead(String url) {
    return _executeRequest(client.headUrl(Uri.parse(url)));
  }

  @override
  Future<int> executeOptions(String url) {
    return _executeRequest(client.openUrl("option", Uri.parse(url)));
  }

  @override
  Future<int> executePatch(String url) {
    return _executeRequestWithBody(
        client.patchUrl(Uri.parse(url)), "assets/patch.json");
  }

  @override
  Future<int> executePost(String url) {
    return _executeRequestWithBody(
        client.postUrl(Uri.parse(url)), "assets/post.json");
  }

  @override
  Future<int> executePut(String url) {
    return _executeRequestWithBody(
        client.putUrl(Uri.parse(url)), "assets/put.json");
  }

  @override
  Future<int> executeTrace(String url) {
    return _executeRequest(client.openUrl("trace", Uri.parse(url)));
  }

  Future<int> _executeRequest(Future<HttpClientRequest> requestFuture) {
    return requestFuture.then((request) {
      return request.close();
    }).then((response) {
      Utf8Decoder().bind(response).listen((data) {
        print("Client IO has received: $data");
      });
      return response.statusCode;
    });
  }

  Future<int> _executeRequestWithBody(
      Future<HttpClientRequest> requestFuture, String bodyAssetName) async {
    final body = await rootBundle.load(bodyAssetName);
    return requestFuture.then((request) {
      request.headers.add(HttpHeaders.contentTypeHeader, "application/json");
      request.add(body.buffer.asUint8List());
      return request.close();
    }).then((response) {
      Utf8Decoder().bind(response).listen((data) {
        print("Client IO has received: $data");
      });
      return response.statusCode;
    });
  }
}

class DioHttpClient extends AppHttpClient {

  final Dio dio = new Dio();

  @override
  Future<int> executeDelete(String url) {
    return dio.delete(url).then((response) {
      return response.statusCode;
    });
  }

  @override
  Future<int> executeGet(String url) {
    return dio.get(url).then((response) {
      return response.statusCode;
    });
  }

  @override
  Future<int> executeGetImage() {
    return dio.get("https://raw.githubusercontent.com/appspector/android-sdk/master/images/github-cover.png").then((response) {
      return response.statusCode;
    });
  }

  @override
  Future<int> executeHead(String url) {
    return dio.head(url).then((response) {
      return response.statusCode;
    });
  }

  @override
  Future<int> executeOptions(String url) {
    throw Exception("OPTION request is not supported by current client");
  }

  @override
  Future<int> executePatch(String url) {
    return dio.patch(url).then((response) {
      return response.statusCode;
    });
  }

  @override
  Future<int> executePost(String url) {
    final data = {
      'eventId': 1,
      'companyId': 201,
      'jobRoleId': '3',
      'expressBadge': false,
      'fcmToken': 'svsdfvdsvf'
    };
    return dio.post(url, data: data).then((response) {
      return response.statusCode;
    });
  }

  @override
  Future<int> executePut(String url) {
    return dio.put(url).then((response) {
      return response.statusCode;
    });
  }

  @override
  Future<int> executeTrace(String url) {
    throw Exception("TRACE request is not supported by current client");
  }
}
