import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:rabbit_jump/components/starting_platform.dart';
import 'package:rabbit_jump/components/player.dart';
import 'package:flame/events.dart';

class MyPlatformGame extends FlameGame with DragCallbacks {
  late Player player;
  late StartingPlatform platform;
  Vector2? dragStart;

  double get platformTopY => platform.position.y - platform.size.y;

  @override
  Color backgroundColor() => const Color(0xFF87CEEB); // 하늘색 배경

  @override
  Future<void> onLoad() async {
    platform = await StartingPlatform.load(
      game: this,
      imagePath: 'assets/spritesheet_jumper.png',
      xmlPath: 'assets/spritesheet_jumper.xml',
      spriteName: 'ground_grass.png',
    );
    add(platform);

    player = await Player.load(
      game: this,
      imagePath: 'assets/spritesheet_jumper.png',
      xmlPath: 'assets/spritesheet_jumper.xml',
      spriteName: 'bunny2_stand.png',
      position: Vector2(
        platform.size.x / 2,
        platformTopY,
      ),
      scale: 0.5,
    );
    add(player);
  }

  @override
  void onDragStart(DragStartEvent event) {
    dragStart = event.canvasPosition;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (dragStart != null && event.canvasEndPosition != null) {
      final deltaX = event.canvasEndPosition!.x - dragStart!.x;
      if (deltaX > 20) {
        player.direction = 1;
      } else if (deltaX < -20) {
        player.direction = -1;
      } else {
        player.direction = 0;
      }
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    player.direction = 0;
  }
}
