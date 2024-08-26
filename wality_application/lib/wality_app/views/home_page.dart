import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wality_application/wality_app/views/nav_bar/floating_action_button.dart';
import 'package:wality_application/wality_app/views/nav_bar/custom_bottom_navbar.dart';
import 'package:wality_application/wality_app/views_models/animation_vm.dart';
import 'package:wality_application/wality_app/views_models/water_save_vm.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
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
                    padding: const EdgeInsets.only(bottom: 60),
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
                      const SizedBox(height: 8),
                      const Padding(
                        padding: EdgeInsets.only(left: 20.0),
                        child: Text(
                          "John Doe",
                          //'Hello! ${uservm.user.name}',
                          style: TextStyle(
                            fontSize: 36,
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
                              padding: const EdgeInsets.only(bottom: 8, top: 4),
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
                                    child: SizedBox(
                                      width:
                                          280, // Slightly smaller to fit inside the border
                                      height:
                                          280, // Slightly smaller to fit inside the border
                                      child: AnimatedBuilder(
                                        animation: animationvm
                                            .waveAnimationController!,
                                        builder: (context, child) {
                                          return CustomPaint(
                                            painter: WavePainter(
                                                animationvm
                                                    .waveAnimationController!
                                                    .value,
                                                watervm.getFillRatio()),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Text(
                                      '${watervm.water.mlSaved}/${watervm.water.maxMl}ml',
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
                            const SizedBox(height: 2),
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
                              padding: const EdgeInsets.only(bottom: 40),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (animationvm.gifBytes2 != null)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 40),
                                      child: Column(
                                        children: [
                                          Image.memory(
                                            animationvm.gifBytes!,
                                            width: 80, // Set desired width
                                            height: 80, // Set desired height
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
                                    padding: const EdgeInsets.only(
                                        bottom: 40, right: 20),
                                    child: Text(
                                      '${watervm.water.savedCount}',
                                      style: const TextStyle(
                                        fontSize: 96,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'RobotoCondensed',
                                      ),
                                    ),
                                  ),
                                  if (animationvm.gifBytes != null)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 40),
                                      child: Column(
                                        children: [
                                          Image.memory(
                                            animationvm.gifBytes2!,
                                            width: 80, // Set desired width
                                            height: 80, // Set desired height
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
                        )),
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
