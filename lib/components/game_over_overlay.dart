import 'package:flutter/material.dart';

class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'GAME OVER',
        style: TextStyle(
          fontSize: 48,
          color: Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}