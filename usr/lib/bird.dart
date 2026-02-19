import 'package:flutter/material.dart';

class MyBird extends StatelessWidget {
  final double birdY;
  final double birdWidth;
  final double birdHeight;

  const MyBird({
    super.key, 
    required this.birdY, 
    required this.birdWidth, 
    required this.birdHeight
  });

  @override
  Widget build(BuildContext context) {
    // Convert relative size to screen percentage for alignment
    // Alignment (0,0) is center. (-1, -1) is top left. (1, 1) is bottom right.
    
    return Container(
      alignment: Alignment(0, (2 * birdY + birdHeight) / (2 - birdHeight)),
      child: Image.asset(
        'assets/images/bird.png', // We will use an icon if image fails or just a container for now
        width: MediaQuery.of(context).size.height * birdWidth,
        height: MediaQuery.of(context).size.height * birdHeight,
        fit: BoxFit.fill,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.flutter_dash, color: Colors.white, size: 35),
          );
        },
      ),
    );
  }
}
