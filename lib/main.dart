import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'components/my_platform_game.dart';
import 'components/game_over_overlay.dart';

void main() {
  runApp(
    MaterialApp(
      home: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final MyPlatformGame game;

  @override
  void initState() {
    super.initState();
    game = MyPlatformGame(onScoreChanged: () {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GameWidget(
          game: game,
          overlayBuilderMap: {
            'GameOver': (context, game) => const GameOverOverlay(),
          },
        ),
        Positioned(
          top: 32,
          left: 24,
          child: Text(
            'Score: ${game.score}',
            style: const TextStyle(
              fontSize: 28,
              color: Colors.black,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(blurRadius: 2, color: Colors.white)],
            ),
          ),
        ),
      ],
    );
  }
}