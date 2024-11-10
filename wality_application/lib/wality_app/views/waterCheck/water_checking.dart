// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'dart:math';

import 'package:wality_application/wality_app/utils/navigator_utils.dart';
import 'package:wality_application/wality_app/views_models/animation_vm.dart';

class WaterChecking extends StatefulWidget {
  final int? sentCurrentWater;
  final int? sentCurrentBottle;
  final int? sentWaterAmount;

  const WaterChecking({
    super.key,
    this.sentCurrentWater,
    this.sentCurrentBottle,
    this.sentWaterAmount,
  });

  @override
  _WaterCheckingState createState() => _WaterCheckingState();
}

class _WaterCheckingState extends State<WaterChecking>
    with TickerProviderStateMixin {
  int mlSaved = 0;
  int maxMl = 550;
  int savedCount = 0;
  int fillCount = 0;
  bool _isFillingStopped = false;
  int incrementAmount = 1;
  int totalAmountToFill = 0;
  int initialTotalAmountToFill =
      0; // New variable to store the original input amount
  int remainingAmount = 0;
  int totalWaterFilled = 0; // Track total water filled
  late AnimationController _waveAnimationController;
  late AnimationController _fillLevelController;
  late Animation<double> _fillLevelAnimation;
  late AnimationController _splashController;
  late Animation<double> _splashAnimation;
  late AnimationViewModel animationvm;

  @override
  void initState() {
    super.initState();
    animationvm = AnimationViewModel(this);
    mlSaved = widget.sentCurrentWater ?? 0;
    savedCount = widget.sentCurrentBottle ?? 0;
    totalAmountToFill = widget.sentWaterAmount ?? 0;

    _waveAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _fillLevelController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fillLevelAnimation =
        Tween<double>(begin: 0.0, end: mlSaved / maxMl).animate(CurvedAnimation(
      parent: _fillLevelController,
      curve: Curves.linear, // Use linear curve for more accurate filling
    ));

    _splashController = AnimationController(
      duration: const Duration(milliseconds: 1500),
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
                  savedCount += 1;
                }

                totalWaterFilled += mlSaved; // Update the total water filled
                mlSaved = 0;
                _fillLevelAnimation = Tween<double>(begin: 0.0, end: 0.0)
                    .animate(_fillLevelController);
                fillCount++;

                if (remainingAmount > 0) {
                  totalAmountToFill = remainingAmount;
                  remainingAmount = 0;
                  _isFillingStopped = false;
                  startWaterFilling();
                } else {
                  // Show the popup after filling is complete
                  showWaterFilledPopup(context);
                }
              });
              _splashController.reset();
            }
          });

    initialTotalAmountToFill =
        totalAmountToFill; // Store the initial input amount
    startWaterFilling();
  }

  @override
  void dispose() {
    _waveAnimationController.dispose();
    _fillLevelController.dispose();
    _splashController.dispose();
    super.dispose();
  }

  void startWaterFilling() {
    if (totalAmountToFill > maxMl) {
      remainingAmount = totalAmountToFill - maxMl;
      totalAmountToFill = maxMl;
    }

    setWaterIncrement(incrementAmount);
  }

  void setWaterIncrement(int increment) {
    if (_isFillingStopped) return;

    setState(() {
      int previousMlSaved = mlSaved;
      mlSaved += increment;

      // Ensure we don't exceed the target amount
      if (mlSaved > totalAmountToFill) {
        mlSaved = totalAmountToFill;
      }

      // Calculate the exact fill level
      double targetFillLevel = mlSaved / maxMl;
      double currentFillLevel = previousMlSaved / maxMl;

      // Create a new animation from the current level to the target level
      _fillLevelAnimation = Tween<double>(
        begin: currentFillLevel,
        end: targetFillLevel,
      ).animate(CurvedAnimation(
        parent: _fillLevelController,
        curve: Curves.linear,
      ));

      _fillLevelController.forward(from: 0);

      if (mlSaved >= totalAmountToFill) {
        if (!_splashController.isAnimating) {
          _splashController.forward();
        }
        _isFillingStopped = true;
      }
    });

    if (!_isFillingStopped) {
      // Calculate delay based on total amount to ensure smooth filling
      int delayDuration = initialTotalAmountToFill >= 1650 ? 20 : 20;

      // Adjust increment based on total amount for smoother animation
      int adjustedIncrement = (totalAmountToFill > maxMl) ? 2 : 1;

      Future.delayed(Duration(milliseconds: delayDuration), () {
        setWaterIncrement(adjustedIncrement);
      });
    }
  }

  void showWaterFilledPopup(BuildContext context) {
    String formattedWaterAmount = '';
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    if (totalWaterFilled >= 1000) {
      int liters = totalWaterFilled ~/ 1000;
      int remainingMl = totalWaterFilled % 1000;
      formattedWaterAmount =
          '$liters L${remainingMl > 0 ? ' and $remainingMl ml' : ''}';
    } else {
      formattedWaterAmount = '$totalWaterFilled ml';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
                    // Returning false here prevents the back button from closing the dialog
                    return false;
                  },
          child: AlertDialog(
            backgroundColor: const Color(0xFF003545),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Congratulations!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            content: SingleChildScrollView(
              // Make content scrollable if necessary
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Adjusts to fit content
                  children: [
                    Text(
                      "Now, You just save:",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8), // Add spacing
                    Image.memory(
                      animationvm.gifBytes!,
                      width: screenWidth * 0.3, // Responsive width
                      height: screenHeight * 0.15, // Responsive height
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "$formattedWaterAmount${savedCount > 0 ? " and $savedCount plastic bottle${savedCount > 1 ? 's' : ''}" : ""}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (savedCount > 0) ...[
                      const SizedBox(height: 8), // Add spacing
                      Image.memory(
                        animationvm.gifBytes2!,
                        width: screenWidth * 0.3, // Responsive width
                        height: screenHeight * 0.15, // Responsive height
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "$savedCount marine lives!",
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8), // Add spacing
                      Image.asset(
                        'assets/images/wCoin.png',
                        width: screenWidth * 0.3, // Responsive width
                        height: screenHeight * 0.15, // Responsive height
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 8),
                      Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: "You got ",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            TextSpan(
                              text:
                                  "$savedCount W Coin${savedCount > 1 ? 's' : ''}!",
                              style: const TextStyle(
                                color: Colors.yellow,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      "Every 1 bottle saved = 1 W Coin and marine life saved!",
                      style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 26, 121, 150),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    openHomePage(context);
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
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
                  const SizedBox(height: 20),
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
                                      offset: const Offset(5, 5),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 10,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 280,
                                height: 280,
                                child: ClipOval(
                                  child: AnimatedBuilder(
                                    animation: Listenable.merge([
                                      _waveAnimationController,
                                      _fillLevelAnimation
                                    ]),
                                    builder: (context, child) {
                                      return CustomPaint(
                                        painter: WavePainter(
                                          _waveAnimationController.value,
                                          _fillLevelAnimation.value,
                                          maxMl,
                                          mlSaved,
                                        ),
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
                                      size: const Size(400, 400),
                                    );
                                  },
                                ),
                              Center(
                                child: Text(
                                  '$mlSaved/$maxMl ml',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'You saved',
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '$savedCount',
                            style: const TextStyle(
                              fontSize: 48,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 10.0), // Adjust padding to create space
                            child: Image.asset(
                              'assets/images/turtle1.png',
                              width: 150,
                              height: 150,
                            ),
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
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final double animationValue;
  final double fillRatio;
  final int maxMl;
  final int currentMl;

  WavePainter(this.animationValue, this.fillRatio, this.maxMl, this.currentMl);

  @override
  void paint(Canvas canvas, Size size) {
    double waveHeight = size.height * fillRatio;

    // Adjust wave amplitude based on fill level
    double amplitude = 10 * (1 - (currentMl / maxMl)).clamp(0.3, 1.0);

    Paint paint = Paint()
      ..color = const Color(0xFF4FC3F7).withOpacity(0.6)
      ..style = PaintingStyle.fill;

    Path path = Path();
    for (double i = 0; i <= size.width; i++) {
      path.lineTo(
        i,
        size.height -
            waveHeight -
            sin((i / size.width * 2 * pi) + (animationValue * 2 * pi)) *
                amplitude,
      );
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // Second wave with adjusted phase and amplitude
    paint.color = const Color(0xFF0288D1).withOpacity(0.6);
    path = Path();
    for (double i = 0; i <= size.width; i++) {
      path.lineTo(
        i,
        size.height -
            waveHeight -
            sin((i / size.width * 2 * pi) +
                    (animationValue * 2 * pi) +
                    pi / 2) *
                (amplitude * 0.8),
      );
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.fillRatio != fillRatio ||
        oldDelegate.currentMl != currentMl;
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
      double endX = size.width / 2 + cos(angle) * (maxRadius + 60 * progress);
      double endY = size.height / 2 + sin(angle) * (maxRadius + 60 * progress);

      paint.color = Colors.blueAccent.withOpacity((1.0 - progress) * 0.6);
      paint.strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint..strokeWidth = 8 * (1.0 - progress),
      );
    }

    // Draw water droplets
    for (int i = 0; i < 30; i++) {
      final randomAngle = Random().nextDouble() * 2 * pi;
      final randomRadius = radius + Random().nextDouble() * 80 * progress;
      final x = (size.width / 2) + randomRadius * cos(randomAngle);
      final y = (size.height / 2) + randomRadius * sin(randomAngle);

      paint.color = Colors.blueAccent.withOpacity((1.0 - progress) * 0.5);
      canvas.drawCircle(Offset(x, y), 8 * (1 - progress), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
