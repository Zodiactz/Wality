import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wality_application/wality_app/utils/navigator_utils.dart';
import 'package:wality_application/wality_app/views_models/water_checking_vm.dart';

class WaterCheckingPage extends StatelessWidget {
  final File image;

  const WaterCheckingPage({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return ChangeNotifierProvider(
      create: (_) => WaterCheckingViewModel(image),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0083AB), Color(0xFF003545)],
            ),
          ),
          child: SafeArea(
            child: Consumer<WaterCheckingViewModel>(
              builder: (context, watercheckingvm, child) {
                return Column(
                  children: [
                    _buildAppBar(context),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            children: [
                              const SizedBox(height: 24),
                              _buildImageContainer(watercheckingvm),
                              const SizedBox(height: 24),
                              _buildConfirmButton(context, screenWidth),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.chevron_left,
                color: Colors.white,
                size: 32,
              ),
              onPressed: () => GoBack(context),
            ),
            const Expanded(
              child: Text(
                'Clearness Reader',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'RobotoCondensed',
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 40), // Balance the back button
          ],
        ),
      ),
    );
  }

  Widget _buildImageContainer(WaterCheckingViewModel watercheckingvm) {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          watercheckingvm.image,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context, double screenWidth) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ElevatedButton(
        onPressed: () => _showResultDialog(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.2),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Confirm',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'RobotoCondensed',
          ),
        ),
      ),
    );
  }

  void _showResultDialog(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 8,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0083AB),
                  Colors.white,
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: const Text(
                    "Water Clearness Result",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'RobotoCondensed',
                    ),
                  ),
                ),

                // Content
                SingleChildScrollView(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        // Image with decoration
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/images/Good_water.png',
                            width: screenWidth * 0.2,
                            height: screenWidth * 0.2,
                            fit: BoxFit.contain,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Result text with custom container
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'The Water has a good clearness!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF0083AB),
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'RobotoCondensed',
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'The turbidity value of this water is around 0',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 18,
                                  fontFamily: 'RobotoCondensed',
                                ),
                              ),
                              const SizedBox(height: 15),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0083AB),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Accuracy: 90%',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'RobotoCondensed',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Exit Button
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            openHomePage(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0083AB),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 3,
                          ),
                          child: const Text(
                            'Exit',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'RobotoCondensed',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
