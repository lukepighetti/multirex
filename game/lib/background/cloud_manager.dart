import 'package:flame/components.dart';
import 'package:trex_game/background/cloud.dart';
import 'package:trex_game/trex_game.dart';

class CloudManager extends PositionComponent with HasGameRef<TRexGame> {
  final double cloudFrequency = 0.5;
  final int maxClouds = 20;
  final double bgCloudSpeed = 0.3;

  void addCloud() {
    final cloudPosition = Vector2(
      2000 + Cloud.initialSize.x + 10,
      absolutePosition.y / 2 + Cloud.skyLevel - absolutePosition.y,
    );
    add(Cloud(position: cloudPosition));
  }

  double get cloudSpeed => bgCloudSpeed / 1000 * gameRef.currentSpeed;

  @override
  void update(double dt) {
    super.update(dt);
    final numClouds = children.length;
    if (numClouds > 0) {
      final lastCloud = children.last as Cloud;
      if (numClouds < maxClouds && (2000 / 2 - lastCloud.x) > Cloud.cloudGap) {
        addCloud();
      }
    } else {
      addCloud();
    }
  }

  void reset() {
    removeAll(children);
  }
}
