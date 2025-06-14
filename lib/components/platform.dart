import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:xml/xml.dart';

class Platform extends SpriteComponent with HasGameReference<FlameGame> {
  Platform({
    required Sprite sprite,
    required Vector2 size,
    required Vector2 position,
  }) : super(sprite: sprite, size: size, position: position, anchor: Anchor.bottomLeft);

  static Future<Platform> create({
    required FlameGame game,
    required String imagePath,
    required String xmlPath,
    required String spriteName,
    required Vector2 position,
    double widthScale = 1.0,
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

    final sprite = Sprite(image,
        srcPosition: Vector2(x, y), srcSize: Vector2(width, height));
    final screenWidth = game.size.x;
    final scale = screenWidth / width * widthScale;
    final verticalScale = 0.5;
    final scaledSize = Vector2(screenWidth * widthScale, height * scale * verticalScale);

    return Platform(sprite: sprite, size: scaledSize, position: position);
  }
}
// The Platform class represents a platform in the game.