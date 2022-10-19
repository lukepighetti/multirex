import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:trex_game/background/cloud_manager.dart';
import 'package:trex_game/trex_game.dart';

class Cloud extends SpriteComponent
    with ParentIsA<CloudManager>, HasGameRef<TRexGame> {
  Cloud({required Vector2 position})
      : super(
          position: position,
          size: initialSize,
        );

  static Vector2 initialSize = Vector2(92.0, 28.0);

  static const double cloudGap = 400.0;
  static const double skyLevel = 60.0;

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
