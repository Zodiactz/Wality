import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wality_application/wality_app/utils/LoadingOverlay.dart';
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
      child: Consumer<WaterCheckingViewModel>(
        builder: (context, watercheckingvm, child) {
          return LoadingOverlay(
            isLoading: watercheckingvm.isLoading,
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
                  child: Column(
                    children: [
                      _buildAppBar(context),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
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
                  ),
                ),
              ),
            ),
          );
        },
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

  Future<void> _handleImageDeletion(
      BuildContext context, String imageURL) async {
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
    final viewModel = Provider.of<WaterCheckingViewModel>(context, listen: false);
    viewModel.setLoading(true);

    try {
      final userService = UserService();
      final uploadedUrl = await userService.uploadImage(image);

      if (uploadedUrl != null) {
        final inferenceResult = await userService.runRoboflowInference(uploadedUrl);
        print(uploadedUrl);

        viewModel.setLoading(false);

        if (inferenceResult != null && inferenceResult['outputs'] != null) {
          final ntuLevel = _extractNtuLevel(inferenceResult);
          _showResultDialog(context, uploadedUrl, ntuLevel);
        } else {
          _showErrorDialog(context);
        }
      } else {
        viewModel.setLoading(false);
        _showErrorDialog(context);
      }
    } catch (e) {
      viewModel.setLoading(false);
      _showErrorDialog(context);
    }
  }

  String _extractNtuLevel(Map<String, dynamic> inferenceResult) {
    try {
      if (inferenceResult['outputs'] != null &&
          inferenceResult['outputs'].isNotEmpty) {
        final outputs = inferenceResult['outputs'][0];
        print(outputs);

        if (outputs['predictions'] != null &&
            outputs['predictions']['predictions'] is List) {
          final predictions = outputs['predictions']['predictions'];
          print(predictions);

          // Sort predictions by confidence in descending order
          predictions.sort((a, b) =>
              (b['confidence'] as num).compareTo(a['confidence'] as num));

          // Look for NTU class in predictions
          for (var prediction in predictions) {
            if (prediction['class'].toString().startsWith('NTU_')) {
              // Extract the number after 'NTU_'
              return prediction['class'].toString().replaceAll('NTU_', '');
            }
          }
        }
      }
      print("No NTU prediction found in result: $inferenceResult");
      return 'N/A';
    } catch (e) {
      print("Error extracting NTU level: $e");
      print("Result structure: $inferenceResult");
      return 'N/A';
    }
  }

  void _showResultDialog(
      BuildContext context, String uploadedUrl, String ntuLevel) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Determine the result image, text, and colors based on the NTU level
    String resultImage;
    String resultText;
    Color resultTextColor;
    List<Color> gradientColors; // Add gradient colors variable

    if (ntuLevel == 'N/A') {
      resultImage = 'assets/images/No_water.png';
      resultText = 'Water not detected!';
      resultTextColor = Colors.grey;
      gradientColors = const [Colors.grey, Colors.white];
    } else {
      // Convert ntuLevel to double for comparison
      double ntuValue = double.tryParse(ntuLevel) ?? 0;

      if (ntuValue > 5) {
        resultImage = 'assets/images/Bad_water.png';
        resultText = 'The water has a bad clearness!';
        resultTextColor = Colors.red;
        gradientColors = const [
          Colors.red,
          Colors.white
        ]; // Red gradient for bad results
      } else {
        resultImage = 'assets/images/Good_water.png';
        resultText = "The water has a good clearness!";
        resultTextColor = const Color(0xFF0083AB);
        gradientColors = const [
          Color(0xFF0083AB),
          Colors.white
        ]; // Blue gradient for good results
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
      onWillPop: () async {
        return false;
      },
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            elevation: 8,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: gradientColors, // Use dynamic gradient colors
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                  SingleChildScrollView(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        children: [
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
                              resultImage,
                              width: screenWidth * 0.2,
                              height: screenWidth * 0.2,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 20),
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
                                  style: TextStyle(
                                    color: resultTextColor,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'RobotoCondensed',
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  "The turbidity of the water is around $ntuLevel NTU",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 22,
                                    fontFamily: 'RobotoCondensed',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              _handleImageDeletion(context, uploadedUrl);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  resultTextColor, // Use the result color for the button
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
                  ),
                ],
              ),
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
      description: 'Position your device camera directly above the water sample.',
      highlightedText: 'Use camera flashlight when taking a photo.\nMake sure there isn\'t any reflection!',
    ),
    TutorialStep(
      image: 'assets/images/waterAnalyze.png',
      title: 'Analyze Water',
      description: 'Our AI will analyze the water clarity and provide NTU measurements.',
      highlightedText: '',
    ),
    TutorialStep(
      image: 'assets/images/waterCheck.png',
      title: 'View Results',
      description: 'Get detailed results about water clarity and recommendations.',
      highlightedText: '',
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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 160, // Reduced from 180
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
            const SizedBox(height: 16), // Reduced from 24
            Text(
              step.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'RobotoCondensed',
              ),
            ),
            const SizedBox(height: 12), // Reduced from 16
            Text(
              step.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
                fontFamily: 'RobotoCondensed',
              ),
            ),
            if (step.highlightedText.isNotEmpty) ...[
              const SizedBox(height: 12), // Reduced from 16
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), // Reduced vertical padding
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.15),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 4,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.cyan.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        step.highlightedText,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.3, // Reduced from 1.4
                          color: Colors.white.withOpacity(0.95),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: const Offset(0, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8), // Added bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Container(
      padding: const EdgeInsets.only(bottom: 8), // Added padding
      child: Row(
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
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20), // Adjusted padding
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          const SizedBox(height: 8), // Reduced from 10
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
  final String highlightedText;

  TutorialStep({
    required this.image,
    required this.title,
    required this.description,
    required this.highlightedText,
  });
}
