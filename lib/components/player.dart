import 'package:flame/components.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:xml/xml.dart';
import 'package:flame/game.dart';

class Player extends SpriteComponent with HasGameReference<FlameGame> {
  Player({
    required Sprite sprite,
    required Vector2 size,
    required Vector2 position,
  }) : super(
    sprite: sprite,
    size: size,
    position: position,
    anchor: Anchor.bottomCenter,
  );

  static Future<Player> load({
    required FlameGame game,
    required String imagePath,
    required String xmlPath,
    required String spriteName,
    required Vector2 position,
    double scale = 1.0,
  }) async {
    final image = await game.images.load(imagePath);
    final xmlString = await rootBundle.loadString(xmlPath);
    final document = XmlDocument.parse(xmlString);

    final element = document
        .findAllElements('SubTexture')
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

    final scaledSize = Vector2(width, height) * scale;

    return Player(
      sprite: sprite,
      size: scaledSize,
      position: position,
    );
  }
}

//이것은 찬영이가 하는 test입니다