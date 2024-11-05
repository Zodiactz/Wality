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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return ChangeNotifierProvider(
      create: (_) => WaterCheckingViewModel(image),
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 40),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF0083AB),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: AppBar(
                backgroundColor: const Color(0xFF0083AB),
                elevation: 0,
                automaticallyImplyLeading: false,
                leading: IconButton(
                  icon: const Icon(
                    Icons.chevron_left,
                    size: 32,
                  ),
                  onPressed: () {
                    GoBack(context);
                  },
                ),
                title: const Padding(
                  padding: EdgeInsets.only(right: 50),
                  child: Center(
                    child: Text(
                      'Clearness Reader',
                      style: TextStyle(
                        fontSize: 24,
                        fontFamily: 'RobotoCondensed',
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        body: Consumer<WaterCheckingViewModel>(
          builder: (context, watercheckingvm, child) {
            return Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFD6F1F3),
                        Color(0xFF0083AB),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.1, 1.0],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 320, top: 150),
                  child: Center(
                    child: SingleChildScrollView(
                      // Added to make content scrollable
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 340,
                            height: 250,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0),
                              image: DecorationImage(
                                image: FileImage(watercheckingvm.image),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            // Make the button full width
                            child: ElevatedButton(
                              onPressed: () {
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
                    const SizedBox(height: 20),
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
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF342056),
                                minimumSize: Size(screenWidth * 0.8, 50),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 24),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Confirm',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'RobotoCondensed',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
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
    );
  }
}
