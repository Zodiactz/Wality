import 'package:flutter/material.dart';
import 'dart:math';

class NewWaterChecking extends StatefulWidget {
  @override
  _NewWaterCheckingState createState() => _NewWaterCheckingState();
}

class _NewWaterCheckingState extends State<NewWaterChecking>
    with TickerProviderStateMixin {
  int mlSaved = 0;
  int maxMl = 550;
  int savedCount = 0;
  int fillCount = 0;
  bool _isFillingStopped = false;
  int incrementAmount = 1; // Default increment amount for water level
  int totalAmountToFill = 600; // Set the desired total amount of water here
  int remainingAmount = 0; // To track the remaining water to fill across cycles
  late AnimationController _waveAnimationController;
  late AnimationController _fillLevelController;
  late Animation<double> _fillLevelAnimation;
  late AnimationController _splashController;
  late Animation<double> _splashAnimation;

  @override
  void initState() {
    super.initState();

    _waveAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _fillLevelController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _fillLevelAnimation = Tween<double>(begin: 0.0, end: mlSaved / maxMl)
        .animate(_fillLevelController);

    _splashController = AnimationController(
      duration: Duration(milliseconds: 1500), // Duration for splash effect
      vsync: this,
    );

    _splashAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _splashController,
      curve: Curves.easeOutQuart,
    ))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              setState(() {
                if (mlSaved == maxMl) {
                  savedCount += 1; // Increment savedCount only if mlSaved is maxMl
                }

                mlSaved = 0; // Reset mlSaved to zero after splash
                _fillLevelAnimation = Tween<double>(begin: 0.0, end: 0.0)
                    .animate(_fillLevelController);
                fillCount++; // Increment the fill count

                // Continue filling if there is remaining water
                if (remainingAmount > 0) {
                  totalAmountToFill = remainingAmount;
                  remainingAmount = 0;
                  _isFillingStopped = false; // Allow filling to continue
                  startWaterFilling();
                }
              });
              _splashController.reset();
            }
          });

    // Start the filling process with the specified amount
    startWaterFilling();
  }

  @override
  void dispose() {
    _waveAnimationController.dispose();
    _fillLevelController.dispose();
    _splashController.dispose();
    super.dispose();
  }

  // Method to start filling water based on the specified total amount
  void startWaterFilling() {
    // If there is more water to fill than the max capacity for one cycle
    if (totalAmountToFill > maxMl) {
      remainingAmount = totalAmountToFill - maxMl;
      totalAmountToFill = maxMl;
    }

    setWaterIncrement(incrementAmount);
  }

  // Method to increment the water level
  void setWaterIncrement(int increment) {
    if (_isFillingStopped) return; // Stop filling if the process is stopped

    setState(() {
      mlSaved += increment;
      if (mlSaved >= totalAmountToFill) {
        // If water reaches or exceeds totalAmountToFill, trigger splash animation
        mlSaved = totalAmountToFill; // Ensure mlSaved does not exceed totalAmountToFill

        if (!_splashController.isAnimating) {
          _splashController.forward();
        }

        // Stop filling for this cycle
        _isFillingStopped = true;
      }

      _fillLevelAnimation = Tween<double>(
        begin: _fillLevelAnimation.value,
        end: mlSaved / maxMl,
      ).animate(_fillLevelController);

      _fillLevelController.forward(from: 0);
    });

    // Continue filling until we reach the totalAmountToFill
    if (!_isFillingStopped) {
      Future.delayed(Duration(milliseconds: 50), () {
        setWaterIncrement(increment); // Recursively call to increment water level
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF003545), Color(0xFF0083AB)],
                  stops: [0.0, 0.67],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 300,
                              height: 300,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: Offset(5, 5),
                                  ),
                                ],
                                border: Border.all(
                                  color:
                                      const Color.fromARGB(255, 255, 255, 255),
                                  width: 10,
                                ),
                              ),
                            ),
                            ClipOval(
                              child: Container(
                                width: 280,
                                height: 280,
                                child: AnimatedBuilder(
                                  animation: _waveAnimationController,
                                  builder: (context, child) {
                                    return CustomPaint(
                                      painter: WavePainter(
                                          _waveAnimationController.value,
                                          _fillLevelAnimation.value),
                                    );
                                  },
                                ),
                              ),
                            ),
                            if (_splashController.isAnimating)
                              AnimatedBuilder(
                                animation: _splashAnimation,
                                builder: (context, child) {
                                  return CustomPaint(
                                    painter: OutsideSplashPainter(
                                        _splashAnimation.value),
                                    size: Size(400,
                                        400), // Increased size for a larger splash effect
                                  );
                                },
                              ),
                            Center(
                              child: Text(
                                '$mlSaved/$maxMl ml',
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Text(
                          'You saved',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$savedCount',
                          style: TextStyle(
                            fontSize: 48,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Image.asset(
                          'assets/images/turtle1.png',
                          width: 150, // Adjust width as needed
                          height: 150, // Adjust height as needed
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final double animationValue;
  final double fillRatio;

  WavePainter(this.animationValue, this.fillRatio);

  @override
  void paint(Canvas canvas, Size size) {
    double waveHeight = size.height * fillRatio;
    Paint paint = Paint()
      ..color = Color(0xFF4FC3F7).withOpacity(0.6)
      ..style = PaintingStyle.fill;

    Path path = Path();
    for (double i = 0; i <= size.width; i++) {
      path.lineTo(
        i,
        size.height -
            waveHeight -
            sin((i / size.width * 2 * pi) + (animationValue * 2 * pi)) * 10,
      );
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    paint.color = Color(0xFF0288D1).withOpacity(0.6);
    path = Path();
    for (double i = 0; i <= size.width; i++) {
      path.lineTo(
        i,
        size.height -
            waveHeight -
            sin((i / size.width * 2 * pi) +
                    (animationValue * 2 * pi) +
                    pi / 2) *
                10,
      );
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class OutsideSplashPainter extends CustomPainter {
  final double progress;

  OutsideSplashPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.0;

    double maxRadius = size.width / 2;
    double radius = maxRadius * progress;

    // Draw splash arcs
    for (int i = 0; i < 12; i++) {
      double angle = (pi / 6) * i;
      double startX = size.width / 2 + cos(angle) * maxRadius;
      double startY = size.height / 2 + sin(angle) * maxRadius;
      double endX = size.width / 2 +
          cos(angle) * (maxRadius + 60 * progress);
      double endY = size.height / 2 +
          sin(angle) * (maxRadius + 60 * progress);

      paint.color = Colors.blueAccent.withOpacity((1.0 - progress) * 0.6);
      paint.strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint
          ..strokeWidth = 8 * (1.0 - progress),
      );
    }

    // Draw water droplets
    for (int i = 0; i < 30; i++) {
      final randomAngle = Random().nextDouble() * 2 * pi;
      final randomRadius =
          radius + Random().nextDouble() * 80 * progress;
      final x = (size.width / 2) + randomRadius * cos(randomAngle);
      final y = (size.height / 2) + randomRadius * sin(randomAngle);

      paint.color = Colors.blueAccent.withOpacity((1.0 - progress) * 0.5);
      canvas.drawCircle(
          Offset(x, y), 8 * (1 - progress), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
