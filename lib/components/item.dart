import 'package:flame/components.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:xml/xml.dart';
import 'package:flame/game.dart';

class Item extends SpriteComponent with HasGameRef<FlameGame> {
  final String type; // 'jetpack' 또는 'wings'

  Item({
    required Sprite sprite,
    required Vector2 size,
    required Vector2 position,
    required this.type,
  }) : super(sprite: sprite, size: size, position: position, anchor: Anchor.center);

  static Future<Item> load({
    required FlameGame game,
    required String imagePath,
    required String xmlPath,
    required String spriteName,
    required Vector2 position,
    required String type,
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

    return Item(
      sprite: sprite,
      size: size,
      position: position,
      type: type,
    );
  }
}
//item