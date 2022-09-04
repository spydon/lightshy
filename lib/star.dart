import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/geometry.dart';
import 'package:flutter/material.dart';
import 'package:lightshy/lightshy.dart';
import 'package:lightshy/player.dart';

class Star extends PositionComponent with HasGameRef<LightShy>, HasPaint {
  Star({required super.position, this.isFriendly = false}) : super(priority: 1);

  bool isFriendly;
  Ray2? ray;
  Ray2? reflection;
  late final speed = isFriendly ? 10 : 100;
  final inertia = 5.0;
  final safetyDistance = 50;
  final direction = Vector2(0, 1);
  final velocity = Vector2.zero();
  final random = Random();

  final _colorTween = ColorTween(
    begin: ColorExtension.random(base: 70).withOpacity(0.3),
    end: ColorExtension.random(base: 70).withOpacity(0.3),
  );

  static const numberOfRays = 2000;
  final List<Ray2> rays = [];
  final List<RaycastResult<ShapeHitbox>> results = [];

  late Path path;
  @override
  Future<void> onLoad() async {}

  final _velocityModifier = Vector2.zero();

  var _timePassed = 0.0;

  @override
  void update(double dt) {
    super.update(dt);
    _timePassed += dt;
    paint.color = _colorTween.transform(0.5 + (sin(_timePassed) / 2))!;
    gameRef.collisionDetection.raycastAll(
      position,
      numberOfRays: numberOfRays,
      rays: rays,
      out: results,
    );
    velocity.scale(inertia);
    const rayRange = numberOfRays / 20;
    for (var i = 0; i < results.length; i++) {
      final result = results[i];
      if (result.hitbox?.parent is Player) {
        (result.hitbox?.parent as Player).startShrinking();
      }
      if (!result.isActive || i % rayRange != 0) {
        continue;
      }
      _velocityModifier
        ..setFrom(result.intersectionPoint!)
        ..sub(position)
        ..normalize();
      if (result.distance! < safetyDistance) {
        _velocityModifier.negate();
      } else if (random.nextDouble() < 0.2) {
        velocity.add(_velocityModifier);
      }
      velocity.add(_velocityModifier);
    }
    velocity
      ..normalize()
      ..scale(speed * dt);
    position.add(velocity);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    for (final result in results) {
      if (!result.isActive) {
        continue;
      }
      final intersectionPoint = result.intersectionPoint!.toOffset();
      canvas.drawLine(
        Offset.zero,
        intersectionPoint - position.toOffset(),
        paint,
      );
    }
    canvas.drawCircle(Offset.zero, 5, paint);
  }
}
