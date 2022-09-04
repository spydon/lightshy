import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:lightshy/lightshy.dart';
import 'package:lightshy/random_extension.dart' as random_extension;

enum ZoneShape {
  rectangle,
  circle;

  static ZoneShape random() {
    return random_extension.random.fromList<ZoneShape>(ZoneShape.values);
  }
}

class SafeZone extends PositionComponent with HasGameRef<LightShy>, HasPaint {
  SafeZone({required super.position, required super.size})
      : shape = ZoneShape.random(),
        super(priority: -1);

  final ZoneShape shape;

  Effect? _colorEffect;
  bool get isActive => _colorEffect != null;
  void deactivate() {
    _colorEffect?.reset();
    _colorEffect?.removeFromParent();
    _colorEffect = null;
  }

  @override
  Future<void> onLoad() async {
    paint = BasicPalette.black.paint();
    late ShapeHitbox hitbox;
    late ShapeComponent shapeComponent;
    switch (shape) {
      case ZoneShape.circle:
        size = Vector2.all(min(size.x, size.y));
        hitbox = CircleHitbox();
        shapeComponent = CircleComponent(radius: size.x / 2);
        break;
      case ZoneShape.rectangle:
        hitbox = RectangleHitbox();
        shapeComponent = RectangleComponent(size: size);
        break;
    }
    hitbox
      ..renderShape = true
      ..paint = paint
      ..collisionType = CollisionType.passive;
    shapeComponent.paint
      ..color = Colors.white70
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    add(hitbox);
    add(shapeComponent);
  }

  void setActive() {
    add(
      _colorEffect = ColorEffect(
        Colors.white70,
        const Offset(0, 1),
        EffectController(
          duration: gameRef.zoneLightDuration,
          curve: Curves.decelerate,
          alternate: true,
        ),
        onComplete: () => _colorEffect = null,
      ),
    );
  }
}
