import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/services.dart';
import 'package:lightshy/lightshy.dart';
import 'package:lightshy/safe_zone.dart';

class Player extends CircleComponent
    with HasGameRef<LightShy>, KeyboardHandler, CollisionCallbacks {
  Player({required super.position}) : super(anchor: Anchor.center, radius: 20);

  final Vector2 velocity = Vector2.zero();
  final double speed = 200;
  bool isShrinking = false;

  @override
  Future<void> onLoad() async {
    add(CircleHitbox());

    void constantShrinking() {
      final delta = size.x - 1 < 0 ? -size : Vector2.all(-1);
      add(
        SizeEffect.by(
          delta,
          EffectController(duration: 1),
          onComplete: constantShrinking,
        ),
      );
    }

    constantShrinking();
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.addScaled(velocity, dt * speed);
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final isKeyDown = event is RawKeyDownEvent;

    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      velocity.x = isKeyDown ? -1 : 0;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      velocity.x = isKeyDown ? 1 : 0;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      velocity.y = isKeyDown ? -1 : 0;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      velocity.y = isKeyDown ? 1 : 0;
    }

    return false;
  }

  void startShrinking() {
    if (!isShrinking) {
      final nextSize = size.x - 5 < 0 ? -size : Vector2.all(-5);
      add(
        SizeEffect.by(
          nextSize,
          EffectController(duration: 1),
          onComplete: () => isShrinking = false,
        ),
      );
      isShrinking = true;
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is SafeZone && other.isActive) {
      add(
        SizeEffect.by(
          Vector2.all(10),
          EffectController(duration: 1, curve: Curves.easeInExpo),
        ),
      );
      other.deactivate();
    }
  }
}
