import 'package:flame/components.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:xml/xml.dart';
import 'package:flame/game.dart';

class WingmanObstacle extends SpriteComponent with HasGameReference<FlameGame> {
  double speed = 100;
  int direction = 1;

  WingmanObstacle({
    required Sprite sprite,
    required Vector2 size,
    required Vector2 position,
  }) : super(sprite: sprite, size: size, position: position, anchor: Anchor.bottomCenter);

  static Future<WingmanObstacle> load({
    required FlameGame game,
    required String imagePath,
    required String xmlPath,
    required String spriteName,
    required Vector2 position,
    double scale = 0.7,
  }) async {
    final image = await game.images.load(imagePath);
    final xmlString = await rootBundle.loadString(xmlPath);
    final document = XmlDocument.parse(xmlString);
    final element = document.findAllElements('SubTexture')
        .firstWhere((e) => e.getAttribute('name') == spriteName);

    final x = double.parse(element.getAttribute('x')!);
    final y = double.parse(element.getAttribute('y')!);
    final width = double.parse(element.getAttribute('width')!);
    final height = double.parse(element.getAttribute('height')!);

    final sprite = Sprite(
      image,
      srcPosition: Vector2(x, y),
      srcSize: Vector2(width, height),
    );
    final size = Vector2(width, height) * scale;

    return WingmanObstacle(
      sprite: sprite,
      size: size,
      position: position,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x += speed * direction * dt;

    final gameWidth = game.size.x;

    if (position.x - size.x / 2 <= 0) {
      position.x = size.x / 2;
      direction = 1;
    } else if (position.x + size.x / 2 >= gameWidth) {
      position.x = gameWidth - size.x / 2;
      direction = -1;
    }
  }
}
// The WingmanObstacle class represents an obstacle that moves horizontally across the screen.
