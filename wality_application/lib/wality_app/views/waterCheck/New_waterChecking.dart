import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';

class NewWaterChecking extends StatefulWidget {
  @override
  _NewWaterCheckingState createState() => _NewWaterCheckingState();
}

class _NewWaterCheckingState extends State<NewWaterChecking> with TickerProviderStateMixin {
  int mlSaved = 0;
  int maxMl = 550;
  int savedCount = 0;
  int fillCount = 0; // Counter for the number of fills
  bool _isFillingStopped = false; // Flag to stop filling
  late AnimationController _waveAnimationController;
  late AnimationController _turtleAnimationController;
  late Animation<double> _turtleAnimation;
  Uint8List? gifBytes;

  late AnimationController _fillLevelController;
  late Animation<double> _fillLevelAnimation;

  late AnimationController _splashController;
  late Animation<double> _splashAnimation;

  @override
  void initState() {
    super.initState();
    _loadGif();

    _waveAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _turtleAnimationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _turtleAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(_turtleAnimationController);

    _fillLevelController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _fillLevelAnimation = Tween<double>(begin: 0.0, end: mlSaved / maxMl).animate(_fillLevelController);

    _splashController = AnimationController(
      duration: Duration(milliseconds: 1500), // Duration for splash effect
      vsync: this,
    );

    _splashAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _splashController,
      curve: Curves.easeOutQuart,
    ))..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          mlSaved = 0; // Reset mlSaved to zero after splash
          _fillLevelAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(_fillLevelController);
          fillCount++; // Increment the fill count

          if (fillCount >= 2) {
            // Show popup after two fills
            _isFillingStopped = true; // Stop filling
            _showCongratulationsPopup();
          }
        });
        _splashController.reset(); // Reset splash controller for the next cycle
      }
    });

    _incrementWaterLevel(1); // Start filling the water level incrementally
  }

  Future<void> _loadGif() async {
    try {
      final ByteData data = await rootBundle.load('assets/turtle.gif');
      setState(() {
        gifBytes = data.buffer.asUint8List();
      });
    } catch (e) {
      print('Error loading GIF: $e');
    }
  }

  @override
  void dispose() {
    _waveAnimationController.dispose();
    _turtleAnimationController.dispose();
    _fillLevelController.dispose();
    _splashController.dispose();
    super.dispose();
  }

  void _incrementWaterLevel(int increment) {
    if (_isFillingStopped) return; // Stop filling if the process is stopped

    setState(() {
      mlSaved += increment;
      if (mlSaved > maxMl) {
        // If water exceeds maxMl, trigger splash animation
        if (!_splashController.isAnimating) {
          _splashController.forward();
          setState(() {
            savedCount += 1; // Increment the saved count
          });
        }
        mlSaved -= maxMl; // Reset mlSaved after splash
      }

      _fillLevelAnimation = Tween<double>(
        begin: _fillLevelAnimation.value,
        end: mlSaved / maxMl,
      ).animate(_fillLevelController);

      _fillLevelController.forward(from: 0);
    });

    // Call increment again with a delay to simulate continuous filling
    Future.delayed(Duration(milliseconds: 50), () {
      _incrementWaterLevel(increment); // Recursively call to increment water level
    });
  }

  void _showCongratulationsPopup() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing the dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Congratulations!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'You have reduced one plastic bottle\nand helped a turtle.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.of(context).pushReplacementNamed('/homepage'); // Navigate to Homepage
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text('OK'),
              ),
            ],
          ),
        );
      },
    );
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
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Text(
                    'Hello, Note!',
                    style: TextStyle(
                      fontSize: 36,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
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
                                  color: const Color.fromARGB(255, 255, 255, 255),
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
                                      painter: WavePainter(_waveAnimationController.value, _fillLevelAnimation.value),
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
                                    painter: OutsideSplashPainter(_splashAnimation.value),
                                    size: Size(400, 400), // Increased size for a larger splash effect
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
                        SizedBox(height: 10),
                        if (gifBytes != null)
                          AnimatedBuilder(
                            animation: _turtleAnimation,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(MediaQuery.of(context).size.width * _turtleAnimation.value, 0),
                                child: child,
                              );
                            },
                            child: Image.memory(
                              gifBytes!,
                              width: 250,
                              height: 250,
                            ),
                          )
                        else
                          CircularProgressIndicator(),
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
        size.height - waveHeight - sin((i / size.width * 2 * pi) + (animationValue * 2 * pi)) * 10,
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
        size.height - waveHeight - sin((i / size.width * 2 * pi) + (animationValue * 2 * pi) + pi) * 10,
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
    for (int i = 0; i < 12; i++) { // Increased from 8 to 12 for more splash lines
      double angle = (pi / 6) * i; // Evenly spaced around the circle
      double startX = size.width / 2 + cos(angle) * maxRadius;
      double startY = size.height / 2 + sin(angle) * maxRadius;
      double endX = size.width / 2 + cos(angle) * (maxRadius + 60 * progress); // Increased length for a bigger splash
      double endY = size.height / 2 + sin(angle) * (maxRadius + 60 * progress); // Increased length for a bigger splash

      paint.color = Colors.blueAccent.withOpacity((1.0 - progress) * 0.6);
      paint.strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint..strokeWidth = 8 * (1.0 - progress), // Increased line thickness for more visibility
      );
    }

    // Draw water droplets
    for (int i = 0; i < 30; i++) { // Increased number of droplets
      final randomAngle = Random().nextDouble() * 2 * pi;
      final randomRadius = radius + Random().nextDouble() * 80 * progress; // Increased range for droplets
      final x = (size.width / 2) + randomRadius * cos(randomAngle);
      final y = (size.height / 2) + randomRadius * sin(randomAngle);

      paint.color = Colors.blueAccent.withOpacity((1.0 - progress) * 0.5);
      canvas.drawCircle(Offset(x, y), 8 * (1 - progress), paint); // Increased droplet size
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
