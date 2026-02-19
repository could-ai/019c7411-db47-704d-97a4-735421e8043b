import 'dart:async';
import 'package:flutter/material.dart';
import 'bird.dart';
import 'barriers.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Game Physics Variables
  static double birdYaxis = 0;
  double time = 0;
  double height = 0;
  double initialHeight = birdYaxis;
  bool gameHasStarted = false;
  int score = 0;
  int highScore = 0;

  // Barrier Variables
  static double barrierXone = 1;
  double barrierXtwo = barrierXone + 1.5;
  
  // Barrier Heights (randomize these in a real scenario, fixed for simplicity now)
  // Heights are relative to screen size (0.0 to 1.0 approx)
  // Total height available is ~1.5 to leave a gap
  List<List<double>> barrierHeight = [
    [0.6, 0.4], // [topHeight, bottomHeight]
    [0.4, 0.6],
  ];

  // Game Settings
  double gravity = -4.9; // Gravity strength
  double velocity = 2.5; // Jump strength
  double birdWidth = 0.1; // Relative to screen width
  double birdHeight = 0.1; // Relative to screen height

  void jump() {
    setState(() {
      time = 0;
      initialHeight = birdYaxis;
    });
  }

  void startGame() {
    gameHasStarted = true;
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      // Physics Equation: y = -1/2 * g * t^2 + v * t
      // Adjusted for screen coordinates (-1 to 1)
      time += 0.04;
      height = -4.9 * time * time + 2.8 * time;
      
      setState(() {
        birdYaxis = initialHeight - height;
        
        // Move Barriers
        if (barrierXone < -2) {
          barrierXone += 3.5;
        } else {
          barrierXone -= 0.05;
        }

        if (barrierXtwo < -2) {
          barrierXtwo += 3.5;
        } else {
          barrierXtwo -= 0.05;
        }
      });

      // Check Game Over
      if (birdIsDead()) {
        timer.cancel();
        _showDialog();
      }
    });
  }

  bool birdIsDead() {
    // Check if bird hits top or bottom of screen
    if (birdYaxis > 1 || birdYaxis < -1) {
      return true;
    }

    // Check collision with Barrier 1
    // Barrier X range is approx barrierX +/- width
    // Barrier Y range is determined by height
    if (checkCollision(barrierXone, barrierHeight[0][0], barrierHeight[0][1])) {
      return true;
    }

    // Check collision with Barrier 2
    if (checkCollision(barrierXtwo, barrierHeight[1][0], barrierHeight[1][1])) {
      return true;
    }

    return false;
  }

  bool checkCollision(double barrierX, double topHeight, double bottomHeight) {
    // Simple AABB collision detection logic adapted for the coordinate system
    // Bird is at 0 horizontally (center)
    // Barrier width is approx 0.5 in relative coordinates (needs tuning based on UI)
    
    // Check Horizontal Collision
    // The bird is centered at 0. The barrier moves from right (1) to left (-1).
    // We need to check if the barrier is crossing the center.
    // Barrier width visual is roughly 0.2 screen width.
    
    bool horizontalCollision = (barrierX >= -0.2 && barrierX <= 0.2);
    
    if (horizontalCollision) {
      // Check Vertical Collision
      // Top pipe goes from -1 down to (some value)
      // Bottom pipe goes from 1 up to (some value)
      
      // Convert relative heights to Y-axis coordinates
      // Top pipe lower bound: -1 + topHeight (roughly)
      // Bottom pipe upper bound: 1 - bottomHeight (roughly)
      
      // Note: This logic is simplified. In a robust engine we'd use exact pixel/rect intersection.
      // Here we approximate:
      // If birdY is "too high" (less than top limit) or "too low" (greater than bottom limit)
      
      // Adjusting for the coordinate system where -1 is top, 1 is bottom
      // Top barrier takes up 'topHeight' amount of space from -1.
      // So if birdY < -1 + topHeight (approx), it hits top.
      // Bottom barrier takes up 'bottomHeight' amount of space from 1.
      // So if birdY > 1 - bottomHeight (approx), it hits bottom.
      
      // Let's tune these thresholds based on visual inspection
      // The gap is the safe zone.
      
      // Visual tuning:
      double topLimit = -1.1 + topHeight; // -1.1 to account for border
      double bottomLimit = 1.1 - bottomHeight;
      
      if (birdYaxis < topLimit || birdYaxis > bottomLimit) {
        return true;
      }
    }
    
    return false;
  }

  void resetGame() {
    Navigator.pop(context); // Dismiss dialog
    setState(() {
      birdYaxis = 0;
      gameHasStarted = false;
      time = 0;
      initialHeight = birdYaxis;
      barrierXone = 1;
      barrierXtwo = 1 + 1.5;
      score = 0;
    });
  }

  void _showDialog() {
    if (score > highScore) {
      highScore = score;
    }
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.brown,
          title: const Text(
            "G A M E  O V E R",
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            "Score: $score\nBest: $highScore",
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: resetGame,
              child: const Text(
                "PLAY AGAIN",
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Update score if passed barrier
    if (gameHasStarted) {
      if ((barrierXone < -0.1 && barrierXone > -0.15) || 
          (barrierXtwo < -0.1 && barrierXtwo > -0.15)) {
        // Simple check to increment score once per pass
        // In a real loop we'd use a boolean flag 'passed'
         score++;
      }
    }

    return GestureDetector(
      onTap: () {
        if (gameHasStarted) {
          jump();
        } else {
          startGame();
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              flex: 2,
              child: Stack(
                children: [
                  // Background
                  Container(
                    color: Colors.lightBlueAccent,
                  ),
                  
                  // Bird
                  MyBird(
                    birdY: birdYaxis,
                    birdWidth: birdWidth,
                    birdHeight: birdHeight,
                  ),
                  
                  // Tap to play text
                  Container(
                    alignment: const Alignment(0, -0.3),
                    child: gameHasStarted
                        ? const SizedBox()
                        : const Text(
                            "T A P  T O  P L A Y",
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),

                  // Barrier 1 (Top & Bottom)
                  MyBarrier(
                    barrierX: barrierXone,
                    barrierWidth: 0.4, // Width of pipe
                    barrierHeight: barrierHeight[0][0], // Top height
                    isBottomBarrier: false,
                  ),
                  MyBarrier(
                    barrierX: barrierXone,
                    barrierWidth: 0.4,
                    barrierHeight: barrierHeight[0][1], // Bottom height
                    isBottomBarrier: true,
                  ),

                  // Barrier 2 (Top & Bottom)
                  MyBarrier(
                    barrierX: barrierXtwo,
                    barrierWidth: 0.4,
                    barrierHeight: barrierHeight[1][0],
                    isBottomBarrier: false,
                  ),
                  MyBarrier(
                    barrierX: barrierXtwo,
                    barrierWidth: 0.4,
                    barrierHeight: barrierHeight[1][1],
                    isBottomBarrier: true,
                  ),
                ],
              ),
            ),
            Container(
              height: 15,
              color: Colors.green,
            ),
            Expanded(
              child: Container(
                color: Colors.brown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("SCORE", style: TextStyle(color: Colors.white, fontSize: 20)),
                        const SizedBox(height: 20),
                        Text(score.toString(), style: const TextStyle(color: Colors.white, fontSize: 35)),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("BEST", style: TextStyle(color: Colors.white, fontSize: 20)),
                        const SizedBox(height: 20),
                        Text(highScore.toString(), style: const TextStyle(color: Colors.white, fontSize: 35)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
