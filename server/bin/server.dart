import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';

var app = Router();

void main() async {
  // Setup websocket
  var websocketHandler = webSocketHandler((webSocket) {
    webSocket.stream.listen((rawMessage) {
      final message = WebsocketPayload.fromJsonString(rawMessage);

      switch (message.type) {
        case "ping":
          webSocket.sink.add(WebsocketPayload('pong').toJsonString());
          break;

        default:
          webSocket.sink.add(WebsocketPayload('error',
              payload: {"message": "Unsupported message type"}).toJsonString());
      }
    });
  });

  // Setup routes
  app.get('/health', (Request request) {
    return Response.ok('OK');
  });

  // Setup server
  var handlers = Cascade().add(app).add(websocketHandler).handler;
  var middleware = const Pipeline().addMiddleware(logRequests());
  var s = await shelf.serve(middleware.addHandler(handlers), 'localhost', 8080);
  s.autoCompress = true;
  print('Serving at http://${s.address.host}:${s.port}');
}

class WebsocketPayload {
  WebsocketPayload(this.type, {this.payload = const {}});

  final String type;

  final Map<String, dynamic> payload;

  WebsocketPayload.fromJson(Map<String, dynamic> json)
      : type = json['type'],
        payload = json['payload'] ?? const {};

  factory WebsocketPayload.fromJsonString(String jsonString) =>
      WebsocketPayload.fromJson(jsonDecode(jsonString));

  Map<String, dynamic> toJson() => {'type': type, 'payload': payload};

  String toJsonString() => jsonEncode(toJson());
}
