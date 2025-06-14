import 'package:flame/components.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:xml/xml.dart';
import 'package:flame/game.dart';
import 'my_platform_game.dart';
import 'platform.dart';

class Player extends SpriteComponent with HasGameReference<MyPlatformGame> {
  late Sprite standSprite;
  late Sprite jumpSprite;

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

  double direction = 0;
  final double moveSpeed = 375;
  double velocityY = 0;
  final double gravity = 800;
  final double jumpForce = -800;

  @override
  void update(double dt) {
    super.update(dt);

    // 좌우 이동
    if (direction != 0) {
      position.x += direction * moveSpeed * dt;
      final minX = size.x / 2;
      final maxX = game.size.x - size.x / 2;
      position.x = position.x.clamp(minX, maxX);
    }

    // 중력 적용
    velocityY += gravity * dt;
    position.y += velocityY * dt;

    // 충돌 검사 (발판 전체 검사)
    for (final platform in [game.startPlatform, ...game.platforms]) {
      final topY = platform.position.y - platform.size.y;

      if (topY > position.y + size.y) continue; // 너무 아래는 패스

      if (velocityY >= 0) {  // 아래로 떨어질 때만 검사
        final distanceToPlatform = position.y - topY;

        if (distanceToPlatform >= 0 && distanceToPlatform <= 40) {
          // X축 충돌 추가 검사
          final platformLeft = platform.position.x;
          final platformRight = platform.position.x + platform.size.x;

          final playerLeft = position.x - size.x / 2;
          final playerRight = position.x + size.x / 2;

          final isOverlappingX = playerRight >= platformLeft && playerLeft <= platformRight;

          if (isOverlappingX) {
            position.y = topY;
            velocityY = jumpForce;
            game.onPlatformStepped(platform.position.y);
            break;
          }
        }
      }
    }

    // 점프(위로 이동) 중이면 점프 스프라이트, 아니면 스탠드 스프라이트
    if (velocityY < 0) {
      sprite = jumpSprite;
    } else {
      sprite = standSprite;
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

    // stand sprite
    final standElement = document.findAllElements('SubTexture')
        .firstWhere((e) => e.getAttribute('name') == 'bunny2_stand.png');
    final standX = double.parse(standElement.getAttribute('x')!);
    final standY = double.parse(standElement.getAttribute('y')!);
    final standWidth = double.parse(standElement.getAttribute('width')!);
    final standHeight = double.parse(standElement.getAttribute('height')!);
    final standSprite = Sprite(
      image,
      srcPosition: Vector2(standX, standY),
      srcSize: Vector2(standWidth, standHeight),
    );

    // jump sprite
    final jumpElement = document.findAllElements('SubTexture')
        .firstWhere((e) => e.getAttribute('name') == 'bunny2_jump.png');
    final jumpX = double.parse(jumpElement.getAttribute('x')!);
    final jumpY = double.parse(jumpElement.getAttribute('y')!);
    final jumpWidth = double.parse(jumpElement.getAttribute('width')!);
    final jumpHeight = double.parse(jumpElement.getAttribute('height')!);
    final jumpSprite = Sprite(
      image,
      srcPosition: Vector2(jumpX, jumpY),
      srcSize: Vector2(jumpWidth, jumpHeight),
    );

    // 기본 스프라이트는 stand로
    final scaledSize = Vector2(standWidth, standHeight) * scale;
    final player = Player(
      sprite: standSprite,
      size: scaledSize,
      position: position,
    );
    player.standSprite = standSprite;
    player.jumpSprite = jumpSprite;
    return player;
  }
}
// 이 코드는 Player 클래스를 정의하며, 플레이어의 움직임과 점프 기능을 구현합니다.