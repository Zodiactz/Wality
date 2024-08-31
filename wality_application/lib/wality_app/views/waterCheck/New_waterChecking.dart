import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';

class NewWaterChecking extends StatefulWidget {
  @override
  _NewWaterCheckingState createState() => _NewWaterCheckingState();
}

class _NewWaterCheckingState extends State<NewWaterChecking> with TickerProviderStateMixin {
  int mlSaved = 0; // Initialize mlSaved to 0
  int maxMl = 550;
  int savedCount = 0;
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
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    _splashAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_splashController)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            mlSaved = 0;
            _fillLevelAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(_fillLevelController);
          });
          _splashController.reset();
        }
      });

    _checkAndIncrementSavedCount();
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

  void _checkAndIncrementSavedCount() {
    if (mlSaved < maxMl) {
      setState(() {
        mlSaved++;
        _fillLevelAnimation = Tween<double>(
          begin: _fillLevelAnimation.value,
          end: mlSaved / maxMl,
        ).animate(_fillLevelController);

        _fillLevelController.forward(from: 0);
      });
    } else {
      _splashController.forward();
      setState(() {
        savedCount += 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Set to transparent
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
                                    painter: SplashPainter(_splashAnimation.value),
                                    size: Size(280, 280),
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

class CurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 50);
    var firstControlPoint = Offset(size.width / 2, size.height);
    var firstEndPoint = Offset(size.width, size.height - 50);
    path.quadraticBezierTo(
        firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
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

class SplashPainter extends CustomPainter {
  final double progress;

  SplashPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.blueAccent.withOpacity(1.0 - progress)
      ..style = PaintingStyle.fill;

    double maxRadius = size.width / 2;
    double radius = maxRadius * progress;

    for (int i = 0; i < 5; i++) {
      canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        radius * (1 - i * 0.2),
        paint..color = paint.color.withOpacity(1.0 - i * 0.2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
