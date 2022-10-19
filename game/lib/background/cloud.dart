import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:trex_game/background/cloud_manager.dart';
import 'package:trex_game/random_extension.dart';
import 'package:trex_game/trex_game.dart';

class Cloud extends SpriteComponent
    with ParentIsA<CloudManager>, HasGameRef<TRexGame> {
  Cloud({required Vector2 position})
      : cloudGap = random.fromRange(
          minCloudGap,
          maxCloudGap,
        ),
        super(
          position: position,
          size: initialSize,
        );

  static Vector2 initialSize = Vector2(92.0, 28.0);

  static const double maxCloudGap = 400.0;
  static const double maxSkyLevel = 60.0;

  // Remove variability
  static const double minCloudGap = maxCloudGap;
  static const double minSkyLevel = maxSkyLevel;

  final double cloudGap;

  @override
  Future<void> onLoad() async {
    sprite = Sprite(
      gameRef.spriteImage,
      srcPosition: Vector2(166.0, 2.0),
      srcSize: initialSize,
    );

    add(
      RectangleHitbox(
        size: Vector2(20, 28),
        position: Vector2(21, 0),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isRemoving) {
      return;
    }
    x -= parent.cloudSpeed.ceil() * 50 * dt;

    if (!isVisible) {
      removeFromParent();
    }
  }

  bool get isVisible {
    return x + width > 0;
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
  }
}
