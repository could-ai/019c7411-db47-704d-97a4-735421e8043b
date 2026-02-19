import 'package:flutter/material.dart';

class MyBarrier extends StatelessWidget {
  final double barrierWidth; // out of 1
  final double barrierHeight; // proportion of screen height
  final double barrierX;
  final bool isBottomBarrier;

  const MyBarrier({
    super.key,
    required this.barrierHeight,
    required this.barrierWidth,
    required this.barrierX,
    required this.isBottomBarrier,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment(
        (2 * barrierX + barrierWidth) / (2 - barrierWidth),
        isBottomBarrier ? 1.1 : -1.1,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.green,
          border: Border.all(width: 5, color: Colors.green.shade800),
          borderRadius: BorderRadius.circular(10),
        ),
        width: MediaQuery.of(context).size.width * barrierWidth / 2,
        height: MediaQuery.of(context).size.height * barrierHeight / 2,
      ),
    );
  }
}
