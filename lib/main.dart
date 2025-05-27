import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'components/game.dart'; // MyPlatformGame을 이 파일에 만들었다면

void main() {
  runApp(
    GameWidget.controlled(
      gameFactory: MyPlatformGame.new,
    ),
  );
}