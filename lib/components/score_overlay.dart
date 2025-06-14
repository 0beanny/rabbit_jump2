import 'package:flutter/material.dart';

class ScoreOverlay extends StatelessWidget {
  final int score;

  const ScoreOverlay({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 32,
      left: 24,
      child: Text(
        'Score: $score',
        style: const TextStyle(
          fontSize: 28,
          color: Colors.black,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(blurRadius: 2, color: Colors.white)],
        ),
      ),
    );
  }
}