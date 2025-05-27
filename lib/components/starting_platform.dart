import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:xml/xml.dart';

class StartingPlatform extends SpriteComponent with HasGameReference<FlameGame> {
  StartingPlatform({
    required Sprite sprite,
    required Vector2 size,
  }) : super(
    sprite: sprite,
    size: size,
    position: Vector2.zero(),
    anchor: Anchor.bottomLeft,
  );

  static Future<StartingPlatform> load({
    required FlameGame game,
    required String imagePath,
    required String xmlPath,
    required String spriteName,
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

    final screenWidth = game.size.x;
    final scale = screenWidth / width;
    final scaledSize = Vector2(screenWidth, height * scale);

    final platform = StartingPlatform(sprite: sprite, size: scaledSize);

    // 위치를 화면 아래로 설정
    platform.position = Vector2(0, game.size.y);

    return platform;
  }
}

