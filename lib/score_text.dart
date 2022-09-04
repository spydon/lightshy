import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:lightshy/lightshy.dart';

class ScoreText extends TextComponent with HasGameRef<LightShy> {
  ScoreText() : super(position: Vector2.all(30), priority: 2);

  final baseText = 'Score: %s';

  @override
  Future<void> onLoad() async {
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    text = baseText.replaceFirst('%s', gameRef.score.floor().toString());
  }
}
