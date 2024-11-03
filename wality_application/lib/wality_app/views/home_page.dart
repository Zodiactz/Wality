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

    // Add a post frame callback to show the dialog after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      if (userId == null) {
        _showLoginPopup(context);
      } else {
        // Initialize all data fetching
        try {
          usernameFuture = _userService.fetchUsername(userId);

          // Fetch bottle and water amounts concurrently
          final Future<int?> bottleFuture =
              _userService.fetchBottleAmount(userId);
          final Future<int?> waterFuture =
              _userService.fetchWaterAmount(userId);
          final Future<int?> totalAmountFuture =
              _userService.fetchTotalWater(userId);

          // Wait for both futures to complete
          final results =
              await Future.wait([bottleFuture, waterFuture, totalAmountFuture]);

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
            // Handle error appropriately
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
        // Handle error appropriately
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
          content:
              const Text('User ID is not found. Please login to continue.'),
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

    return ChangeNotifierProvider(
      create: (context) => AnimationViewModel(this),
      child: Consumer2<AnimationViewModel, WaterSaveViewModel>(
        builder: (context, animationvm, watervm, child) {
          return RefreshIndicator(
              onRefresh: refreshData,
              child: Stack(
                children: [
                  // Your existing Positioned.fill widget
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
                          // FutureBuilder widget to display the username
                          child: FutureBuilder<String?>(
                            future: usernameFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  flutter_async.ConnectionState.waiting) {
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
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: screenHeight * 0.01),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Circle
                                      Container(
                                        width: screenWidth * 0.7,
                                        height: screenWidth * 0.7,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.3),
                                              blurRadius: 10,
                                              offset: const Offset(5, 5),
                                            ),
                                          ],
                                          border: Border.all(
                                            color: Colors.white,
                                            width: screenWidth * 0.03,
                                          ),
                                        ),
                                      ),
                                      ClipOval(
                                        child: SizedBox(
                                          width: screenWidth * 0.65,
                                          height: screenWidth * 0.65,
                                          child: AnimatedBuilder(
                                            animation: animationvm
                                                .waveAnimationController!,
                                            builder: (context, child) {
                                              return CustomPaint(
                                                painter: WavePainter(
                                                  animationvm
                                                      .waveAnimationController!
                                                      .value,
                                                  waterAmount?.toDouble() ??
                                                      0, // Pass the actual water amount
                                                  watervm.water.maxMl
                                                      .toDouble(), // Pass the maximum water amount
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      Center(
                                        child: Text(
                                          '${waterAmount ?? 0}/${watervm.water.maxMl}ml',
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.06,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'RobotoCondensed',
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
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
                                  padding: EdgeInsets.only(
                                      bottom: screenHeight * 0.08),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Bottle
                                              if (animationvm.gifBytes2 != null)
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      right: screenWidth * 0.1),
                                                  child: Column(
                                                    children: [
                                                      Image.memory(
                                                        animationvm.gifBytes!,
                                                        width:
                                                            screenWidth * 0.15,
                                                        height:
                                                            screenWidth * 0.15,
                                                        fit: BoxFit.contain,
                                                      ),
                                                      Text(
                                                        "Bottles",
                                                        style: TextStyle(
                                                          fontSize: 24,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontFamily:
                                                              'RobotoCondensed',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              else
                                                const CircularProgressIndicator(),

                                              // Bottle Amount
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 16),
                                                child: Text(
                                                  bottleAmount != null
                                                      ? '$bottleAmount'
                                                      : '?',
                                                  style: TextStyle(
                                                    fontSize:
                                                        screenWidth * 0.13,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily:
                                                        'RobotoCondensed',
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),

                                              // Turtle
                                              if (animationvm.gifBytes != null)
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      left: screenWidth * 0.1),
                                                  child: Column(
                                                    children: [
                                                      Image.memory(
                                                        animationvm.gifBytes2!,
                                                        width:
                                                            screenWidth * 0.15,
                                                        height:
                                                            screenWidth * 0.15,
                                                        fit: BoxFit.contain,
                                                      ),
                                                      Text(
                                                        "Lives",
                                                        style: TextStyle(
                                                          fontSize: 24,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontFamily:
                                                              'RobotoCondensed',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              else
                                                const CircularProgressIndicator(),
                                            ],
                                          ),
                                          SizedBox(
                                              height: screenHeight *
                                                  0.02), // Add spacing between the rows
                                          // Total Amount text
                                          Text(
                                            'Total: ${totalAmount ?? 0} ML',
                                            style: TextStyle(
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
              ));
        },
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final double animationValue;
  final double waterAmount; // Current water amount
  final double maxWaterAmount; // Maximum water amount (capacity)

  WavePainter(this.animationValue, this.waterAmount, this.maxWaterAmount);

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate the fill ratio based on the water amount
    double fillRatio = waterAmount / maxWaterAmount;

    // Make sure the ratio doesn't exceed 1 (100%)
    fillRatio = fillRatio.clamp(0.0, 1.0);

    // Adjust the height of the wave based on the fill ratio
    double waveHeight = size.height * fillRatio;

    Paint paint = Paint()
      ..color = const Color(0xFF4FC3F7).withOpacity(0.6)
      ..style = PaintingStyle.fill;

    // Create the first wave path
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

    // Draw the first wave
    canvas.drawPath(path, paint);

    // Adjust the color for the second wave
    paint.color = const Color(0xFF0288D1).withOpacity(0.6);

    // Create the second wave path
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

    // Draw the second wave
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
