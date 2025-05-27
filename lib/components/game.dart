import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:rabbit_jump/components/starting_platform.dart';

class MyPlatformGame extends FlameGame {
  @override
  Color backgroundColor() => const Color(0xFF87CEEB); // 하늘색 배경

  @override
  Future<void> onLoad() async {
    final platform = await StartingPlatform.load(
      game: this,
      imagePath: 'assets/spritesheet_jumper.png',
      xmlPath: 'assets/spritesheet_jumper.xml',
      spriteName: 'ground_grass.png',
    );

    add(platform);
  }
}
