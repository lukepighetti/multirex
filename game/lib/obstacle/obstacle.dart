import 'package:flame/components.dart';
import 'package:trex_game/obstacle/obstacle_type.dart';
import 'package:trex_game/trex_game.dart';

class Obstacle extends SpriteComponent with HasGameRef<TRexGame> {
  Obstacle({
    required this.settings,
    required this.groupIndex,
  }) : super(size: settings.size);

  final double _gapCoefficient = 0.6;

  bool followingObstacleCreated = false;
  late double gap;
  final ObstacleTypeSettings settings;
  final int groupIndex;

  bool get isVisible => (x + width) > 0;

  @override
  Future<void> onLoad() async {
    sprite = settings.sprite(gameRef.spriteImage);
    x = 4000 + width * groupIndex;
    y = settings.y;
    gap = computeGap(_gapCoefficient, gameRef.currentSpeed);
    addAll(settings.generateHitboxes());
  }

  double computeGap(double gapCoefficient, double speed) {
    final minGap =
        (width * speed * settings.minGap * gapCoefficient).roundToDouble();
    return minGap;
  }

  @override
  void update(double dt) {
    super.update(dt);
    x -= gameRef.currentSpeed * dt;

    if (!isVisible) {
      removeFromParent();
    }
  }
}
