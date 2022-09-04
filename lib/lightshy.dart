import 'package:flame/collisions.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:lightshy/player.dart';
import 'package:lightshy/random_extension.dart';
import 'package:lightshy/safe_zone.dart';
import 'package:lightshy/score_text.dart';
import 'package:lightshy/star.dart';

class LightShy extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents {
  final maxZoneSize = Vector2.all(300);
  final minZoneSize = Vector2.all(50);
  double score = 0.0;
  double timePassed = 0.0;

  @override
  Future<void> onLoad() async {
    children.query<SafeZone>();
    add(ScoreText());
    add(ScreenHitbox());
    add(Star(position: Vector2(650, 750)));
    add(Star(position: Vector2(650, 750)));
    add(Star(position: Vector2(650, 750)));
    add(Star(position: Vector2(650, 750)));
    add(Player(position: Vector2(100, 200)));
    final numberOfZones = (size.x * size.y / maxZoneSize.length2).floor();
    final zones = <SafeZone>[];
    for (var i = 0; i < numberOfZones; i++) {
      late SafeZone zone;
      do {
        final zoneSize = minZoneSize +
            (Vector2.random(random)..multiply(maxZoneSize - minZoneSize));
        final position = Vector2.random(random)..multiply(size - maxZoneSize);
        zone = SafeZone(position: position, size: zoneSize);
      } while (zones.any(
        (existingZone) => existingZone.toRect().overlaps(zone.toRect()),
      ));
      zones.add(zone);
    }
    addAll(zones);
  }

  double timeSinceZoneLight = 0;
  double timeBetweenZoneLight = 5;
  double zoneLightDuration = 3;

  @override
  void update(double dt) {
    super.update(dt);
    timePassed += dt;
    score += 1 + (timePassed / 60) * dt;
    timeSinceZoneLight += dt;
    if (timeSinceZoneLight > timeBetweenZoneLight) {
      final zone = random.fromList(children.query<SafeZone>());
      zone.setActive();
      timeSinceZoneLight = 0;
    }
  }
}
