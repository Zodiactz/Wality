import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wality_application/wality_app/utils/navigator_utils.dart';
import 'package:wality_application/wality_app/views_models/water_checking_vm.dart';

import '../../repo/user_service.dart';

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
        onPressed: () => _handleImageUploadAndShowResult(context),
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
Future<void> _handleImageDeletion(BuildContext context, String imageURL) async {
    final userService = UserService();
    await userService.deleteImageFromFirebase(imageURL);
    openHomePage(context);
  }

  void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: const Text('Failed to process the image. Please try again.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }


  Future<void> _handleImageUploadAndShowResult(BuildContext context) async {
  // Show loading dialog
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    },
  );

  try {
    final userService = UserService();
    final uploadedUrl = await userService.uploadImage(image);

    // Close loading dialog
    Navigator.pop(context);

    if (uploadedUrl != null) {
      // Call the inference method with the uploaded image URL
      final inferenceResult = await userService.runRoboflowInference(uploadedUrl);
      print(uploadedUrl);

      if (inferenceResult != null && inferenceResult['outputs'] != null) {
        // Show the inference results in the result dialog
        _showResultDialog(context, uploadedUrl,inferenceResult);
        print (inferenceResult);
      } else {
        // Show error dialog if inference fails
        _showErrorDialog(context);
      }
    } else {
      _showErrorDialog(context);
    }
  } catch (e) {
    Navigator.pop(context);
    _showErrorDialog(context);
  }
}


  void _showResultDialog(BuildContext context, String uploadedUrl, Map<String, dynamic> inferenceResult) {
  final screenWidth = MediaQuery.of(context).size.width;
  String resultText = inferenceResult['resultText'] ?? 'No result available';
  String accuracy = inferenceResult['accuracy'] != null ? 'Accuracy: ${inferenceResult['accuracy']}%' : '';

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
                            Text(
                              resultText,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF0083AB),
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
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
                              child: Text(
                                accuracy,
                                style: const TextStyle(
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
                          // Delete the image and navigate
                          _handleImageDeletion(context, uploadedUrl);
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
class WaterTutorialPopup extends StatefulWidget {
  final VoidCallback onComplete;
  
  const WaterTutorialPopup({
    super.key,
    required this.onComplete,
  });

  @override
  State<WaterTutorialPopup> createState() => _WaterTutorialPopupState();
}

class _WaterTutorialPopupState extends State<WaterTutorialPopup> {
  final PageController _pageController = PageController();
  bool _doNotShowAgain = false;
  int _currentPage = 0;

 final List<TutorialStep> _tutorialSteps = [
    TutorialStep(
      image: 'assets/images/clearPhoto.png',
      title: 'Take a Clear Photo',
      description:
          "Position your device camera directly above the water sample. **Use camera flashlight when take a photo. Make sure there isn't any reflection**",
    ),
    TutorialStep(
      image: 'assets/images/waterAnalyze.png',
      title: 'Analyze Water',
      description: 'Our AI will analyze the water clarity and provide NTU measurements.',
    ),
    TutorialStep(
      image: 'assets/images/waterCheck.png',
      title: 'View Results',
      description: 'Get detailed results about water clarity and recommendations.',
    ),
  ];

  Future<void> _setTutorialSeen() async {
    if (_doNotShowAgain) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('water_tutorial_seen', true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final popupWidth = size.width * 0.85;
    final popupHeight = size.height * 0.7;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: popupWidth,
        height: popupHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0083AB), Color(0xFF003545)],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _tutorialSteps.length,
                itemBuilder: (context, index) {
                  return _buildTutorialPage(_tutorialSteps[index]);
                },
              ),
            ),
            _buildPageIndicator(),
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTutorialPage(TutorialStep step) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Image.asset(
              step.image,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            step.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'RobotoCondensed',
            ),
          ),
          const SizedBox(height: 16),
          Text(
            step.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              fontFamily: 'RobotoCondensed',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _tutorialSteps.length,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index
                ? Colors.white
                : Colors.white.withOpacity(0.4),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Checkbox(
                value: _doNotShowAgain,
                onChanged: (value) {
                  setState(() => _doNotShowAgain = value ?? false);
                },
                fillColor: MaterialStateProperty.all(Colors.white),
                checkColor: const Color(0xFF0083AB),
              ),
              const Text(
                'Don\'t show again',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'RobotoCondensed',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              await _setTutorialSeen();
              widget.onComplete();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0083AB),
              minimumSize: const Size(200, 45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              'Got it!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'RobotoCondensed',
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class TutorialStep {
  final String image;
  final String title;
  final String description;

  TutorialStep({
    required this.image,
    required this.title,
    required this.description,
  });
}