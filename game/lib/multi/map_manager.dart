import 'dart:ui';

import 'package:trex_game/obstacle/obstacle_type.dart';

class MapManager {
  double _t = 0;

  static const _maxSpacing = 2.2;
  static const _minSpacing = 0.5;
  static const _maxTime = 15.0;

  double _tLast = 0.0;

  ObstacleType? shouldAddObstacle(double dt) {
    _t += dt;

    final _timeProgress = (_t / _maxTime).clamp(0.0, 1.0);
    final _tSpacing = lerpDouble(_maxSpacing, _minSpacing, _timeProgress)!;

    if (_t > _tLast + _tSpacing) {
      _tLast = _t;
      return ObstacleType.cactusSmall;
    } else {
      return null;
    }
  }

  void reset() {
    _t = 0;
    _tLast = 0;
  }
}
