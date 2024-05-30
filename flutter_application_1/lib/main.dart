import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clone Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ClonePage(),
    );
  }
}

class ClonePage extends StatefulWidget {
  @override
  _ClonePageState createState() => _ClonePageState();
}

class _ClonePageState extends State<ClonePage> with TickerProviderStateMixin {
  int mlSaved = 500; // Initial value
  int maxMl = 550; // Maximum value
  int savedCount = 0; // Counter for "You saved" count
  late AnimationController _waveAnimationController;
  late AnimationController _turtleAnimationController;
  late Animation<double> _turtleAnimation;
  Uint8List? gifBytes;

  @override
  void initState() {
    super.initState();
    _loadGif();

    _waveAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _turtleAnimationController = AnimationController(
      duration: const Duration(seconds: 10), // Increased duration for slower movement
      vsync: this,
    )..repeat();

    _turtleAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(_turtleAnimationController);

    // Check initial state
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
    super.dispose();
  }

  void _checkAndIncrementSavedCount() {
    if (mlSaved >= maxMl) {
      setState(() {
        savedCount += 1;
        mlSaved = 0; // Reset mlSaved or set to some value if needed
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double fillRatio = min(mlSaved / maxMl, 1.0); // Ensure fillRatio doesn't exceed 1.0
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: ClipPath(
              clipper: CurvedClipper(),
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
                      fontSize: 36, // Increased font size
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
                                  color: Colors.black,
                                  width: 10,
                                ),
                              ),
                            ),
                            ClipOval(
                              child: Container(
                                width: 280, // Slightly smaller to fit inside the border
                                height: 280, // Slightly smaller to fit inside the border
                                child: AnimatedBuilder(
                                  animation: _waveAnimationController,
                                  builder: (context, child) {
                                    return CustomPaint(
                                      painter: WavePainter(_waveAnimationController.value, fillRatio),
                                    );
                                  },
                                ),
                              ),
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
                        SizedBox(height: 10), // Slightly increase the height
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
                              width: 250, // Set desired width
                              height: 250, // Set desired height
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
