import 'package:trex_game/obstacle/obstacle_type.dart';

class MapManager {
  double _t = 0;

  /// How many seconds between obstacles
  static const double _tSpacing = 1.0;

  double _tLast = 0.0;

  ObstacleType? shouldAddObstacle(double dt) {
    _t += dt;

    if (_t > _tLast + _tSpacing) {
      _tLast = _t;
      return ObstacleType.cactusSmall;
    } else {
      return null;
    }
  }
}
