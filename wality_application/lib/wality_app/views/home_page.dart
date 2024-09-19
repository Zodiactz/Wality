import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wality_application/wality_app/repo/realm_service.dart';
import 'package:wality_application/wality_app/repo/user_service.dart';
import 'package:wality_application/wality_app/repo/water_service.dart';
import 'package:wality_application/wality_app/utils/nav_bar/floating_action_button.dart';
import 'package:wality_application/wality_app/utils/nav_bar/custom_bottom_navbar.dart';
import 'package:wality_application/wality_app/views_models/animation_vm.dart';
import 'package:wality_application/wality_app/views_models/water_save_vm.dart';
import 'package:realm/realm.dart';
import 'package:flutter/src/widgets/async.dart' as flutter_async;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  Future<String?>? usernameFuture;
  final UserService _userService = UserService();
  final WaterService _waterService = WaterService();
  final RealmService _realmService = RealmService();

  @override
  void initState() {
    super.initState();
    _waterService.refreshWaterDataWithState(context, () => setState(() {}));
    final userId = _realmService.getCurrentUserId();
    usernameFuture = _userService.fetchUsername(userId!);
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions using MediaQuery for responsiveness
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return ChangeNotifierProvider(
      create: (context) => AnimationViewModel(this),
      child: Consumer2<AnimationViewModel, WaterSaveViewModel>(
        builder: (context, animationvm, watervm, child) {
          return Scaffold(
            backgroundColor: const Color(0xFF0083AB),
            body: Stack(
              children: [
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: screenHeight * 0.07), // Responsive padding
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
                                    //circle
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
                                                watervm.getFillRatio(),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: Text(
                                        '${watervm.water.mlSaved}/${watervm.water.maxMl}ml',
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.06, // Responsive font size
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'RobotoCondensed',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              //you save text
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
                                padding:
                                    EdgeInsets.only(bottom: screenHeight * 0.08),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    //bottle
                                    if (animationvm.gifBytes2 != null)
                                      Padding(
                                        padding: EdgeInsets.only(
                                            right: screenWidth * 0.1),
                                        child: Column(
                                          children: [
                                            Image.memory(
                                              animationvm.gifBytes!,
                                              width: screenWidth * 0.2,
                                              height: screenWidth * 0.2,
                                            ),
                                            const Text(
                                              "Bottles",
                                              style: TextStyle(
                                                fontSize: 35,
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
                                    Padding(
                                      padding: EdgeInsets.only(
                                          bottom: screenHeight * 0.05,
                                          right: screenWidth * 0.05),
                                      child: Text(
                                        '${watervm.water.savedCount}',
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.2,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'RobotoCondensed',
                                        ),
                                      ),
                                    ),
                                    //turtle
                                    if (animationvm.gifBytes != null)
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: screenWidth * 0.1),
                                        child: Column(
                                          children: [
                                            Image.memory(
                                              animationvm.gifBytes2!,
                                              width: screenWidth * 0.2,
                                              height: screenWidth * 0.2,
                                            ),
                                            const Text(
                                              "Lives",
                                              style: TextStyle(
                                                fontSize: 35,
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
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: const Padding(
                padding: EdgeInsets.only(top: 12),
                child: CustomFloatingActionButton()),
            bottomNavigationBar:
                const CustomBottomNavBar(currentPage: 'HomePage.dart'),
          );
        },
      ),
    );
  }
}
