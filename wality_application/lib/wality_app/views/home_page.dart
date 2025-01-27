// ignore_for_file: implementation_imports

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wality_application/wality_app/repo/realm_service.dart';
import 'package:wality_application/wality_app/repo/user_service.dart';
import 'package:wality_application/wality_app/utils/navigator_utils.dart';
import 'package:wality_application/wality_app/views_models/animation_vm.dart';
import 'package:wality_application/wality_app/views_models/water_save_vm.dart';
import 'package:flutter/src/widgets/async.dart' as flutter_async;

class BottleShape extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    
    // Start from top center for the bottle neck
    path.moveTo(size.width * 0.4, 0);
    
    // Bottle neck
    path.lineTo(size.width * 0.6, 0);
    path.lineTo(size.width * 0.6, size.height * 0.15);
    
    // Bottle shoulder (right side)
    path.quadraticBezierTo(
      size.width * 0.6, size.height * 0.18,
      size.width * 0.8, size.height * 0.2,
    );
    
    // Bottle body (right side)
    path.quadraticBezierTo(
      size.width * 0.95, size.height * 0.25,
      size.width * 0.95, size.height * 0.4,
    );
    path.lineTo(size.width * 0.95, size.height * 0.9);
    
    // Bottle bottom
    path.quadraticBezierTo(
      size.width * 0.95, size.height,
      size.width * 0.5, size.height,
    );
    
    // Bottle bottom (left side)
    path.quadraticBezierTo(
      size.width * 0.05, size.height,
      size.width * 0.05, size.height * 0.9,
    );
    
    // Bottle body (left side)
    path.lineTo(size.width * 0.05, size.height * 0.4);
    path.quadraticBezierTo(
      size.width * 0.05, size.height * 0.25,
      size.width * 0.2, size.height * 0.2,
    );
    
    // Bottle shoulder (left side)
    path.quadraticBezierTo(
      size.width * 0.4, size.height * 0.18,
      size.width * 0.4, size.height * 0.15,
    );
    
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class BottleWaterIndicator extends StatelessWidget {
  final double waterAmount;
  final double maxWaterAmount;
  final Animation<double> waveAnimation;

  const BottleWaterIndicator({
    Key? key,
    required this.waterAmount,
    required this.maxWaterAmount,
    required this.waveAnimation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    final bottleWidth = screenWidth * 0.6;
    final bottleHeight = screenHeight * 0.45;
    
    return Stack(
      alignment: Alignment.center,
      children: [
        // Bottle outline - removed shadow
        Container(
          width: bottleWidth,
          height: bottleHeight,
          child: ClipPath(
            clipper: BottleShape(),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
        ),
        
        // Water waves
        SizedBox(
          width: bottleWidth,
          height: bottleHeight,
          child: ClipPath(
            clipper: BottleShape(),
            child: AnimatedBuilder(
              animation: waveAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: WavePainter(
                    waveAnimation.value,
                    waterAmount,
                    maxWaterAmount,
                  ),
                );
              },
            ),
          ),
        ),
        
        // Water amount text
        Center(
          child: Text(
            '${waterAmount.toInt()}/${maxWaterAmount.toInt()}ml',
            style: TextStyle(
              fontSize: screenWidth * 0.05,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'RobotoCondensed',
            ),
          ),
        ),
      ],
    );
  }
}

class WavePainter extends CustomPainter {
  final double animationValue;
  final double waterAmount;
  final double maxWaterAmount;

  WavePainter(this.animationValue, this.waterAmount, this.maxWaterAmount);

  @override
  void paint(Canvas canvas, Size size) {
    // Adjust the fill ratio calculation to account for bottle neck
    double fillRatio = waterAmount / maxWaterAmount;
    fillRatio = fillRatio.clamp(0.0, 1.0);
    
    // Adjust wave height calculation to account for bottle shape
    // The main body of the bottle starts at 20% from the top
    // So we adjust the wave height calculation accordingly
    double effectiveHeight = size.height * 0.85; // Usable height for water
    double startY = size.height * 0.15; // Starting point after bottle neck
    
    // Calculate wave height from the bottom of the bottle
    double waveHeight = effectiveHeight * fillRatio;
    
    // Adjust wave amplitude based on fill level
    double waveAmplitude = 10 * (1 - fillRatio).clamp(0.2, 1.0);

    Paint paint = Paint()
      ..color = const Color(0xFF4FC3F7).withOpacity(0.6)
      ..style = PaintingStyle.fill;

    // First wave
    Path path = Path();
    path.moveTo(0, size.height);
    
    if (fillRatio > 0) {
      for (double i = 0; i <= size.width; i++) {
        path.lineTo(
          i,
          size.height - waveHeight + 
          sin((i / size.width * 2 * pi) + (animationValue * 2 * pi)) * waveAmplitude,
        );
      }
    }
    
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);

    // Second wave with slightly different color and phase
    paint.color = const Color(0xFF0288D1).withOpacity(0.6);
    path = Path();
    path.moveTo(0, size.height);
    
    if (fillRatio > 0) {
      for (double i = 0; i <= size.width; i++) {
        path.lineTo(
          i,
          size.height - waveHeight + 
          sin((i / size.width * 2 * pi) + (animationValue * 2 * pi) + pi) * waveAmplitude,
        );
      }
    }
    
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  Future<String?>? usernameFuture;
  final UserService _userService = UserService();
  final RealmService _realmService = RealmService();
  bool _mounted = true;

  int? bottleAmount;
  int? waterAmount;
  int? totalAmount;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> _initializeData() async {
    if (!mounted) return;

    final userId = _realmService.getCurrentUserId();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      if (userId == null) {
        _showLoginPopup(context);
      } else {
        try {
          usernameFuture = _userService.fetchUsername(userId);
          final Future<int?> bottleFuture = _userService.fetchBottleAmount(userId);
          final Future<int?> waterFuture = _userService.fetchWaterAmount(userId);
          final Future<int?> totalAmountFuture = _userService.fetchTotalWater(userId);

          final results = await Future.wait([bottleFuture, waterFuture, totalAmountFuture]);

          if (_mounted) {
            setState(() {
              bottleAmount = results[0];
              waterAmount = results[1];
              totalAmount = results[2];
            });
          }
        } catch (e) {
          if (_mounted) {
            debugPrint('Error initializing data: $e');
          }
        }
      }
    });
  }

  Future<void> refreshData() async {
    if (!mounted) return;

    final userId = _realmService.getCurrentUserId();
    if (userId == null) return;

    try {
      final newBottleAmount = await _userService.fetchBottleAmount(userId);
      final newWaterAmount = await _userService.fetchWaterAmount(userId);
      final newTotalAmount = await _userService.fetchTotalWater(userId);

      if (_mounted) {
        setState(() {
          bottleAmount = newBottleAmount;
          waterAmount = newWaterAmount;
          totalAmount = newTotalAmount;
        });
      }
    } catch (e) {
      if (_mounted) {
        debugPrint('Error refreshing data: $e');
      }
    }
  }

  void _showLoginPopup(BuildContext context) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Login Required'),
          content: const Text('User ID is not found. Please login to continue.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                LogOutToOutsite(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async => false,
      child: ChangeNotifierProvider(
        create: (context) => AnimationViewModel(this),
        child: Consumer2<AnimationViewModel, WaterSaveViewModel>(
          builder: (context, animationvm, watervm, child) {
            return RefreshIndicator(
              onRefresh: refreshData,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: screenHeight * 0.07),
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF0083AB), Color(0xFF003545)],
                            stops: [0.0, 1],
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
                        SizedBox(height: screenHeight * 0.01),
                        Padding(
                          padding: EdgeInsets.only(left: screenWidth * 0.05),
                          child: FutureBuilder<String?>(
                            future: usernameFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == flutter_async.ConnectionState.waiting) {
                                return const Text(
                                  'Loading...',
                                  style: TextStyle(
                                    fontSize: 36,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'RobotoCondensed-Thin',
                                  ),
                                );
                              } else if (snapshot.hasError) {
                                return const Text(
                                  'Error',
                                  style: TextStyle(
                                    fontSize: 36,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'RobotoCondensed-Thin',
                                  ),
                                );
                              } else if (snapshot.hasData) {
                                return Text(
                                  'Hello, ${snapshot.data}!',
                                  style: const TextStyle(
                                    fontSize: 36,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'RobotoCondensed-Thin',
                                  ),
                                );
                              } else {
                                return const Text(
                                  'Username not found',
                                  style: TextStyle(
                                    fontSize: 36,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'RobotoCondensed-Thin',
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                BottleWaterIndicator(
                                  waterAmount: waterAmount?.toDouble() ?? 0,
                                  maxWaterAmount: watervm.water.maxMl.toDouble(),
                                  waveAnimation: animationvm.waveAnimationController!,
                                ),
                                SizedBox(height: screenHeight * 0.01),
                                const Text(
                                  'You saved',
                                  style: TextStyle(
                                    fontSize: 35,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'RobotoCondensed',
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(bottom: screenHeight * 0.08),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              if (animationvm.gifBytes2 != null)
                                                Container(
                                                  width: screenWidth * 0.3,
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Image.memory(
                                                       animationvm.gifBytes!,
                                                        width: screenWidth * 0.15,
                                                        height: screenWidth * 0.15,
                                                        fit: BoxFit.contain,
                                                      ),
                                                      const Text(
                                                        "Bottles",
                                                        style: TextStyle(
                                                          fontSize: 24,
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.bold,
                                                          fontFamily: 'RobotoCondensed',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              else
                                                const CircularProgressIndicator(),

                                              Container(
                                                width: screenWidth * 0.3,
                                                child: Text(
                                                  bottleAmount != null ? '$bottleAmount' : '?',
                                                  style: TextStyle(
                                                    fontSize: screenWidth * 0.13,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'RobotoCondensed',
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),

                                              if (animationvm.gifBytes != null)
                                                Container(
                                                  width: screenWidth * 0.3,
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Image.memory(
                                                        animationvm.gifBytes2!,
                                                        width: screenWidth * 0.15,
                                                        height: screenWidth * 0.15,
                                                        fit: BoxFit.contain,
                                                      ),
                                                      const Text(
                                                        "Lives",
                                                        style: TextStyle(
                                                          fontSize: 24,
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.bold,
                                                          fontFamily: 'RobotoCondensed',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              else
                                                const CircularProgressIndicator(),
                                            ],
                                          ),
                                          SizedBox(height: screenHeight * 0.02),
                                          Text(
                                            'Total: ${totalAmount ?? 0} ML',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'RobotoCondensed',
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
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
            );
          },
        ),
      ),
    );
  }
}