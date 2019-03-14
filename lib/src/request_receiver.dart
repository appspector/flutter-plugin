import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

typedef Future<dynamic> RequestHandler(dynamic args);

class RequestReceiver {
  static const MethodChannel _channel =
      const MethodChannel('appspector_request_channel');
  final Map<String, RequestHandler> handlers = Map();

  RequestReceiver() {
    handlers["take_screenshot"] = _takeScreenshot;
  }

  void observeChannel() {
    _channel.setMethodCallHandler(_handler);
  }

  Future<dynamic> _handler(MethodCall call) async {
    final handler = handlers[call.method];
    if (handler != null) {
      return handler(call.arguments);
    }
    //todo
  }
}

Future<Uint8List> _takeScreenshot(dynamic args) async {
  int maxWidth = args["max_width"];
  var renderViewElement =
      WidgetsFlutterBinding.ensureInitialized().renderViewElement;
  var renderObject = renderViewElement.findRenderObject();
  var ratio = maxWidth / renderObject.paintBounds.width;

  var image = await renderObject.layer
      .toImage(renderObject.paintBounds, pixelRatio: ratio > 1.0 ? 1.0 : ratio);

  var byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData.buffer.asUint8List();
}
