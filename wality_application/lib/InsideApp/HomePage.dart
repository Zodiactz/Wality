import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:wality_application/InsideApp/WaterFilterMachinePage.dart';
import 'package:wality_application/widget/CustomBottomAppBar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  XFile? _selectedImage;
  int mlSaved = 500; // Initial value
  int maxMl = 550; // Maximum value
  int savedCount = 0; // Counter for "You saved" count
  late AnimationController _waveAnimationController;
  late AnimationController _turtleAnimationController;
  Uint8List? gifBytes;
  Uint8List? gifBytes2;

  @override
  void initState() {
    super.initState();
    _loadGif();
    _loadGif2();

    _waveAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _turtleAnimationController = AnimationController(
      duration:
          const Duration(seconds: 10), // Increased duration for slower movement
      vsync: this,
    )..repeat();

    

    // Check initial state
    _checkAndIncrementSavedCount();
  }

  Future<void> _loadGif() async {
    try {
      final ByteData data = await rootBundle.load('assets/gif/turtle.gif');
      setState(() {
        gifBytes = data.buffer.asUint8List();
      });
    } catch (e) {
      print('Error loading GIF: $e');
    }
  }

  Future<void> _loadGif2() async {
    try {
      final ByteData data2 = await rootBundle.load('assets/gif/bottle.gif');
      setState(() {
        gifBytes2 = data2.buffer.asUint8List();
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
    double fillRatio =
        min(mlSaved / maxMl, 1.0); // Ensure fillRatio doesn't exceed 1.0
    return Scaffold(
      backgroundColor: const Color(0xFF0083AB),
      body: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0083AB), Color(0xFF003545)],
                    stops: [0.0, 0.67],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(55),
                    bottomRight: Radius.circular(55),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.only(left: 20.0),
                  child: Text(
                    'Hello, Note!',
                    style: TextStyle(
                      fontSize: 36, // Increased font size
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'RobotoCondensed-Thin',
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Stack(
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
                              ClipOval(
                                child: Container(
                                  width:
                                      280, // Slightly smaller to fit inside the border
                                  height:
                                      280, // Slightly smaller to fit inside the border
                                  child: AnimatedBuilder(
                                    animation: _waveAnimationController,
                                    builder: (context, child) {
                                      return CustomPaint(
                                        painter: WavePainter(
                                            _waveAnimationController.value,
                                            fillRatio),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              Center(
                                child: Text(
                                  '$mlSaved/$maxMl ml',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'RobotoCondensed',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'You saved',
                          style: TextStyle(
                            fontSize: 35,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'RobotoCondensed',
                          ),
                        ),
                        
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (gifBytes2 != null)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 40),
                                    child: Image.memory(
                                      gifBytes2!,
                                      width: 100, // Set desired width
                                      height: 100, // Set desired height
                                    ),
                                  )
                                else
                                  const CircularProgressIndicator(),
                                Text(
                                  '$savedCount',
                                  style: const TextStyle(
                                    fontSize: 96,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'RobotoCondensed',
                                  ),
                                ),
                                if (gifBytes != null)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 40),
                                    child: Image.memory(
                                      gifBytes!,
                                      width: 100, // Set desired width
                                      height: 100, // Set desired height
                                    ),
                                  )
                                else
                                  const CircularProgressIndicator(),
                              ],
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(
          top: 12,
        ),
        child: FloatingActionButton(
          onPressed: () async {
            final ImagePicker picker = ImagePicker();
            final XFile? image = await picker.pickImage(
              source: ImageSource.camera,
            );
            if (image != null) {
              setState(() {});
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      WaterFilterMachinePage(image: File(image.path)),
                ),
              );
            }
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.0),
          ),
          child: Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50.0),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF26CBFF),
                  Color(0xFF6980FD),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: const Icon(Icons.water_drop, color: Colors.black, size: 40),
          ),
        ),
      ),
      bottomNavigationBar:
          const CustomBottomNavBar(currentPage: 'HomePage.dart'),
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
      ..color = const Color(0xFF4FC3F7).withOpacity(0.6)
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

    paint.color = const Color(0xFF0288D1).withOpacity(0.6);
    path = Path();
    for (double i = 0; i <= size.width; i++) {
      path.lineTo(
        i,
        size.height -
            waveHeight -
            sin((i / size.width * 2 * pi) + (animationValue * 2 * pi) + pi) *
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
