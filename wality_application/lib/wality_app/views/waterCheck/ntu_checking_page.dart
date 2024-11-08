import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
