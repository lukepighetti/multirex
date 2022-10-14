import 'dart:collection';

import 'package:flame/components.dart';
import 'package:trex_game/multi/map_manager.dart';
import 'package:trex_game/obstacle/obstacle.dart';
import 'package:trex_game/obstacle/obstacle_type.dart';
import 'package:trex_game/trex_game.dart';

class ObstacleManager extends Component with HasGameRef<TRexGame> {
  ObstacleManager();

  ListQueue<ObstacleType> history = ListQueue();
  static const int maxObstacleDuplication = 1;

  final _mapManager = MapManager();

  @override
  void update(double dt) {
    final obstacle = _mapManager.shouldAddObstacle(dt);

    if (obstacle != null) {
      addNewObstacle(obstacle);
    }
  }

  void addNewObstacle(ObstacleType obstacle) {
    final speed = gameRef.currentSpeed;
    if (speed == 0) {
      return;
    }
    final settings = obstacle == ObstacleType.cactusSmall
        ? ObstacleTypeSettings.cactusSmall
        : ObstacleTypeSettings.cactusLarge;

    final groupSize = _groupSize(settings);
    for (var i = 0; i < groupSize; i++) {
      add(Obstacle(settings: settings, groupIndex: i));
      gameRef.score++;
    }

    history.addFirst(settings.type);
    while (history.length > maxObstacleDuplication) {
      history.removeLast();
    }
  }

  bool duplicateObstacleCheck(ObstacleType nextType) {
    var duplicateCount = 0;

    for (final type in history) {
      duplicateCount += type == nextType ? 1 : 0;
    }
    return duplicateCount >= maxObstacleDuplication;
  }

  void reset() {
    removeAll(children);
    history.clear();
    _mapManager.reset();
  }

  int _groupSize(ObstacleTypeSettings settings) {
    return 1;
  }
}
