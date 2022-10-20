// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

var app = Router();

class GameState {
  GameState(this.socketByPlayerId);

  final Map<String, WeebSocketChannel> socketByPlayerId;

  static const minPlayers = 2;
  static const maxPlayers = 4;

  var status = GameStatus.staging;

  /// The people who are watching the game
  var spectators = <Player>[];

  /// The people that are chosen to play the game
  var players = <Player>[];

  /// The first person to join is the admin
  Player? get admin => players.firstOrNull;

  /// First come first serve
  void joinQueue(Player player) {
    if (players.length < maxPlayers) {
      if (players.isEmpty) {
        player.isAdmin = true;
        eventNewAdmin(player);
      }
      players.add(player);
      eventPlayerAdded(player);
    } else {
      spectators.add(player);
      eventSpectatorAdded(player);
    }
  }

  Future<void> eventNewAdmin(Player player) async {
    socketByPlayerId.values.sendMessage('new-admin', {'playerId': player.id});
  }

  Future<void> eventPlayerAdded(Player player) async {
    socketByPlayerId.values
        .sendMessage('player-added', {'playerId': player.id});
  }

  Future<void> eventSpectatorAdded(Player player) async {
    socketByPlayerId.values
        .sendMessage('spectator-added', {'playerId': player.id});
  }
}

class Player {
  Player({
    required this.id,
  });

  final String id;

  var isAdmin = false;

  final name = "dinooooo";
  final plays = 0;
  final wins = 0;
  final subscriptionType = SubscriptionType.none;
}

enum GameStatus {
  /// When we're waiting for enough people to play a game
  staging,

  /// When there is an active game
  playing,

  /// When we're displaying the results of the previous game
  gameover,
}

/// Twitch subscription type
enum SubscriptionType {
  none,
  following,
  subTier1,
  subTier2,
  subTier3,
}

void main() async {
  final socketByPlayerId = <String, WeebSocketChannel>{};
  final game = GameState(socketByPlayerId);

  // Setup websocket
  var websocketHandler = webSocketHandler((WeebSocketChannel socket) {
    final playerId = Uuid().v4();
    socketByPlayerId[playerId] = socket;

    socket.stream.listen(
      (rawMessage) {
        final message = WebsocketPayload.fromJsonString(rawMessage);
        switch (message.type) {
          case ('join-queue'):
            final player = Player(id: playerId);
            game.joinQueue(player);
            break;
        }
      },
      onError: (_) {
        socket.sendError('WEBSOCKET-ERROR');
        socketByPlayerId.remove(playerId);
      },
      onDone: () {
        socketByPlayerId.remove(playerId);
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

extension on Iterable<WeebSocketChannel> {
  void sendMessage(String type, Map<String, dynamic> payload) {
    for (final socket in this) {
      socket.sendMessage(type, payload);
    }
  }
}

extension on WeebSocketChannel {
  void sendMessage(String type, Map<String, dynamic> payload) {
    return sink.add(WebsocketPayload(type, payload: payload).toJsonString());
  }

  void sendError(String code, [String message = '']) {
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
