// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

var app = Router();

class GameState {
  bool inProgress = false;

  void startGame() {
    inProgress = true;
  }

  void endGame() {
    inProgress = false;
  }
}

void main() async {
  final game = GameState();
  final openSockets = <WeebSocketChannel>{};

  // Setup websocket
  var websocketHandler = webSocketHandler((WebSocketChannel webSocket) {
    openSockets.add(webSocket);

    webSocket.stream.listen(
      (rawMessage) {
        final message = WebsocketPayload.fromJsonString(rawMessage);

        switch (message.type) {
          case "ping":
            webSocket.sink.add(WebsocketPayload('pong').toJsonString());
            break;

          case "start-game":
            if (game.inProgress) {
              webSocket.sendError(
                  'GAME_IN_PROGRESS', 'Game already in progress');
            } else {
              game.startGame();

              // message all websockets that game has started
              openSockets.forEach(
                (e) => e.sink.add(WebsocketPayload('start-game')),
              );
            }
            break;

          case "jump":
            if (!game.inProgress) {
              webSocket.sendError(
                  'GAME_NOT_IN_PROGRESS', 'Game is not in progress');
            } else {
              // message all websockets that a jump occurred
              openSockets.forEach(
                (e) => e.sink.add(WebsocketPayload('jump')),
              );
            }
            break;

          case "ded":
            if (!game.inProgress) {
              webSocket.sendError(
                  'GAME_NOT_IN_PROGRESS', 'Game is not in progress');
            } else {
              game.endGame();

              // message all websockets that a jump occurred
              openSockets.forEach(
                (e) => e.sink.add(WebsocketPayload('ded')),
              );
            }
            break;

          default:
            webSocket.sendError('UNKNOWN_TYPE', 'Unsupported message type');
        }
      },
      onError: (_) {
        openSockets.remove(webSocket);
      },
      onDone: () {
        openSockets.remove(webSocket);
      },
      cancelOnError: true,
    );
  });

  // Setup routes
  app.get('/', (Request request) {
    return Response.ok('OK');
  });

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

typedef WeebSocketChannel = WebSocketChannel;

extension on WeebSocketChannel {
  void sendError(String code, String message) {
    return sink.add(WebsocketPayload(
      'error',
      payload: {"message": message, "code": code},
    ).toJsonString());
  }
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
