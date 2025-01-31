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
  int initialTotalAmountToFill = 0;
  int remainingAmount = 0;
  int totalWaterFilled = 0;
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
      curve: Curves.linear,
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

                totalWaterFilled += mlSaved;
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
                  showWaterFilledPopup(context);
                }
              });
              _splashController.reset();
            }
          });

    initialTotalAmountToFill = totalAmountToFill;
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

      if (mlSaved > totalAmountToFill) {
        mlSaved = totalAmountToFill;
      }

      double targetFillLevel = mlSaved / maxMl;
      double currentFillLevel = previousMlSaved / maxMl;

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
      int delayDuration = initialTotalAmountToFill >= 1650 ? 20 : 20;
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
          onWillPop: () async => false,
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
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Now, You just save:",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Image.memory(
                      animationvm.gifBytes!,
                      width: screenWidth * 0.3,
                      height: screenHeight * 0.15,
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
                      const SizedBox(height: 8),
                      Image.memory(
                        animationvm.gifBytes2!,
                        width: screenWidth * 0.3,
                        height: screenHeight * 0.15,
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
                      const SizedBox(height: 8),
                      Image.asset(
                        'assets/images/wCoin.png',
                        width: screenWidth * 0.3,
                        height: screenHeight * 0.15,
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
                    ],
                    const SizedBox(height: 8),
                    const Text(
                      "Every 1 bottle saved = 1 W Coin and marine life saved!",
                      style: TextStyle(
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
      onWillPop: () async => false,
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
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(5, 5),
                                    ),
                                  ],
                                ),
                              ),
                              ClipPath(
                                clipper: BottleClipper(),
                                child: Container(
                                  width: 280,
                                  height: 280,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                  ),
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
                            padding: const EdgeInsets.only(top: 10.0),
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

class BottleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    
    // Starting from top-center of the bottle cap
    path.moveTo(size.width * 0.4, 0);
    
    // Bottle cap right side
    path.lineTo(size.width * 0.6, 0);
    
    // Bottle neck right side
    path.quadraticBezierTo(
      size.width * 0.6, size.height * 0.1,
      size.width * 0.7, size.height * 0.15
    );
    
    // Bottle body right side
    path.quadraticBezierTo(
      size.width * 0.95,
size.height * 0.2,
      size.width * 0.95, size.height * 0.4
    );
    path.lineTo(size.width * 0.95, size.height * 0.9);
    
    // Bottle bottom right corner
    path.quadraticBezierTo(
      size.width * 0.95, size.height,
      size.width * 0.8, size.height
    );
    
    // Bottle bottom
    path.lineTo(size.width * 0.2, size.height);
    
    // Bottle bottom left corner
    path.quadraticBezierTo(
      size.width * 0.05, size.height,
      size.width * 0.05, size.height * 0.9
    );
    
    // Bottle body left side
    path.lineTo(size.width * 0.05, size.height * 0.4);
    path.quadraticBezierTo(
      size.width * 0.05, size.height * 0.2,
      size.width * 0.3, size.height * 0.15
    );
    
    // Bottle neck left side
    path.quadraticBezierTo(
      size.width * 0.4, size.height * 0.1,
      size.width * 0.4, 0
    );
    
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class WavePainter extends CustomPainter {
  final double animationValue;
  final double fillRatio;
  final int maxMl;
  final int currentMl;

  WavePainter(this.animationValue, this.fillRatio, this.maxMl, this.currentMl);

  @override
  void paint(Canvas canvas, Size size) {
    // Adjust for bottle shape
    double bottleNeckHeight = size.height * 0.15;
    double bottleBodyHeight = size.height - bottleNeckHeight;
    
    // Calculate effective fill height considering bottle shape
    double effectiveFillRatio = fillRatio;
    double waveHeight;
    
    if (fillRatio <= 0.15) {
      // In the neck of the bottle
      waveHeight = bottleNeckHeight * (fillRatio / 0.15);
    } else {
      // In the main body of the bottle
      waveHeight = bottleNeckHeight + (bottleBodyHeight * ((fillRatio - 0.15) / 0.85));
    }

    // Adjust amplitude based on bottle width at current height
    double currentHeight = size.height - waveHeight;
    double bottleWidthAtHeight = getBottleWidthAtHeight(currentHeight, size);
    double amplitude = (bottleWidthAtHeight * 0.05) * (1 - (currentMl / maxMl)).clamp(0.3, 1.0);

    Paint paint = Paint()
      ..color = const Color(0xFF4FC3F7).withOpacity(0.6)
      ..style = PaintingStyle.fill;

    // First wave
    Path path = Path();
    path.moveTo(0, size.height);
    
    for (double i = 0; i <= size.width; i++) {
      double x = i;
      double normalizedX = i / size.width;
      double y = size.height - waveHeight +
          sin((normalizedX * 2 * pi) + (animationValue * 2 * pi)) * amplitude;
      
      // Adjust x position based on bottle shape
      double bottleWidth = getBottleWidthAtHeight(y, size);
      double xOffset = (size.width - bottleWidth) / 2;
      x = xOffset + (normalizedX * bottleWidth);
      
      path.lineTo(x, y);
    }
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);

    // Second wave with different phase
    paint.color = const Color(0xFF0288D1).withOpacity(0.6);
    path = Path();
    path.moveTo(0, size.height);
    
    for (double i = 0; i <= size.width; i++) {
      double x = i;
      double normalizedX = i / size.width;
      double y = size.height - waveHeight +
          sin((normalizedX * 2 * pi) + (animationValue * 2 * pi) + pi / 2) * (amplitude * 0.8);
      
      // Adjust x position based on bottle shape
      double bottleWidth = getBottleWidthAtHeight(y, size);
      double xOffset = (size.width - bottleWidth) / 2;
      x = xOffset + (normalizedX * bottleWidth);
      
      path.lineTo(x, y);
    }
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  double getBottleWidthAtHeight(double height, Size size) {
    double normalizedHeight = height / size.height;
    
    if (normalizedHeight < 0.15) {
      // Neck of the bottle
      return size.width * 0.2;
    } else if (normalizedHeight < 0.2) {
      // Transition from neck to body
      double progress = (normalizedHeight - 0.15) / 0.05;
      return size.width * (0.2 + (0.7 * progress));
    } else {
      // Main body of the bottle
      return size.width * 0.9;
    }
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