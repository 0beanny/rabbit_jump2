import 'package:flame/components.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:xml/xml.dart';
import 'package:flame/game.dart';
import 'package:rabbit_jump/components/game.dart';

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

  double direction = 0;  // -1: 왼쪽, 1: 오른쪽, 0: 정지
  final double moveSpeed = 375;

  double velocityY = 0;
  final double gravity = 800; // 중력 가속도 (픽셀/초^2)
  final double jumpForce = -500; // 점프시 위로 튀는 힘 (음수)

  @override
  void update(double dt) {
    super.update(dt);
    if (direction != 0) {
      position.x += direction * moveSpeed * dt;

      // 화면 밖으로 못나가게 클램핑
      final minX = size.x / 2; // 왼쪽 경계 (anchor가 bottomCenter이니까)
      final maxX = game.size.x - size.x / 2; // 오른쪽 경계

      position.x = position.x.clamp(minX, maxX);
    }

    velocityY += gravity * dt;
    position.y += velocityY * dt;

    // 바닥에 닿으면 다시 점프
    final groundTopY = (game as MyPlatformGame).platformTopY;

    if (position.y >= groundTopY) {
      position.y = groundTopY;
      velocityY = jumpForce;
    }
  }

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