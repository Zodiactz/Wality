import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wality_application/wality_app/utils/LoadingOverlay.dart';
import 'package:wality_application/wality_app/utils/navigator_utils.dart';
import 'package:wality_application/wality_app/views_models/water_checking_vm.dart';
import 'dart:convert';

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
              onPressed: () => openHomePage(context),
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
    return FutureBuilder<Size>(
      future: _getImageSize(watercheckingvm.image),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final imageSize = snapshot.data!;
        final aspectRatio = imageSize.width / imageSize.height;
        final isVertical = aspectRatio < 1;

        return LayoutBuilder(
          builder: (context, constraints) {
            double containerWidth;
            double containerHeight;

            if (isVertical) {
              // For vertical images, set fixed width and let height adjust
              containerWidth =
                  constraints.maxWidth * 0.8; // 80% of screen width
              containerHeight = containerWidth / aspectRatio;
            } else {
              // For horizontal images, maintain original behavior
              containerWidth = constraints.maxWidth;
              containerHeight = containerWidth / aspectRatio;
              // Cap the height for horizontal images
              if (containerHeight > 300) {
                containerHeight = 300;
                containerWidth = containerHeight * aspectRatio;
              }
            }

            return Center(
              child: Container(
                width: containerWidth,
                height: containerHeight,
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
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

// Helper function to get image dimensions
  Future<Size> _getImageSize(File imageFile) async {
    final Completer<Size> completer = Completer();
    final Image image = Image.file(imageFile);
    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener(
        (ImageInfo info, bool _) {
          completer.complete(Size(
            info.image.width.toDouble(),
            info.image.height.toDouble(),
          ));
        },
      ),
    );
    return completer.future;
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

  void _showErrorDialog(BuildContext context, {String? specificError}) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Determine error details based on the context
    String resultImage = 'assets/images/No_water.png';
    String resultText;
    Color resultTextColor = Colors.grey;
    List<Color> gradientColors = const [Colors.grey, Colors.white];
    String troubleshootingText;

    if (specificError == 'UPLOAD_FAILED') {
      resultText = 'Upload Failed!';
      troubleshootingText = 'Please check your internet connection';
    } else if (specificError == 'PROCESSING_FAILED') {
      resultText = 'Processing Failed!';
      troubleshootingText = 'Please ensure the image is clear';
    } else {
      resultText = 'Error Occurred!';
      troubleshootingText = 'Please try again';
    }

    showDialog(
      context: context,
      barrierDismissible: false,
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
                  colors: gradientColors,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: const Text(
                      "Error Processing Image",
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
                                  troubleshootingText,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 22,
                                    fontFamily: 'RobotoCondensed',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            child: ElevatedButton(
                              onPressed: () {
                                openHomePage(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: resultTextColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 3,
                              ),
                              child: const Text(
                                'Go Back',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'RobotoCondensed',
                                ),
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

  Future<void> _handleImageUploadAndShowResult(BuildContext context) async {
    final viewModel =
        Provider.of<WaterCheckingViewModel>(context, listen: false);
    viewModel.setLoading(true);

    try {
      final userService = UserService();
      final uploadedUrl = await userService.uploadImage(image);

      if (uploadedUrl != null) {
        final inferenceResult =
            await userService.runRoboflowInferenceShowImg(uploadedUrl);
        print(uploadedUrl);

        viewModel.setLoading(false);

        if (inferenceResult != null && inferenceResult['outputs'] != null) {
          final ntuLevel = _extractNtuLevel(inferenceResult);

          // Extract the Base64 image from the inference result
          String? base64Image = _extractBase64Image(inferenceResult);

          // Pass the Base64 image to the dialog
          _showResultDialog(context, uploadedUrl, ntuLevel, base64Image!);
        } else {
          _showErrorDialog(context);
          print("1: $inferenceResult");
        }
      } else {
        viewModel.setLoading(false);
        _showErrorDialog(context);
        print("2: $uploadedUrl $viewModel");
      }
    } catch (e) {
      viewModel.setLoading(false);
      _showErrorDialog(context);
      print("3: $e");
    }
  }

  String _extractNtuLevel(Map<String, dynamic> inferenceResult) {
    try {
      // Check if 'outputs' exists and is a non-empty list
      if (inferenceResult.containsKey('outputs') &&
          inferenceResult['outputs'] is List &&
          inferenceResult['outputs'].isNotEmpty) {
        final outputs = inferenceResult['outputs'][0];
        print("Outputs: $outputs");

        // Check if 'predictions' exists and is a list within the 'outputs'
        if (outputs.containsKey('predictions') &&
            outputs['predictions'] is Map &&
            outputs['predictions']['predictions'] is List) {
          final predictions = outputs['predictions']['predictions'];
          print("Predictions: $predictions");

          // Check for 'paperglass' class in predictions
          bool hasPaperglass = predictions.any((prediction) {
            return prediction['class'].toString().toLowerCase() ==
                    'paper_glass' ||
                prediction['class'].toString().toLowerCase() == 'paperglass';
          });

          // If no paperglass is found, return specific message
          if (!hasPaperglass) {
            return 'NO_PAPERGLASS';
          }

          // Sort predictions by confidence in descending order
          predictions.sort((a, b) =>
              (b['confidence'] as num).compareTo(a['confidence'] as num));

          // Look for NTU class in sorted predictions
          for (var prediction in predictions) {
            String className = prediction['class'].toString();
            if (className.startsWith('NTU_')) {
              // Extract the NTU value after 'NTU_'
              return className.replaceAll('NTU_', '');
            }
          }

          // If paperglass is found but no NTU class is present
          return 'WATER_NOT_DETECTED';
        }
      }

      // Log if no valid predictions were found
      print("No valid predictions found in result: $inferenceResult");
      return 'N/A';
    } catch (e) {
      print("Error extracting NTU level: $e");
      print("Result structure: $inferenceResult");
      return 'N/A';
    }
  }

  String? _extractBase64Image(Map<String, dynamic> inferenceResult) {
    try {
      if (inferenceResult['outputs'] != null &&
          inferenceResult['outputs'].isNotEmpty) {
        final outputs = inferenceResult['outputs'][0];

        // Check if the 'bounding_box_visualization' field exists
        if (outputs['bounding_box_visualization'] != null &&
            outputs['bounding_box_visualization']['value'] != null) {
          return outputs['bounding_box_visualization']['value'];
        }
      }
      print("No Base64 image found in result: $inferenceResult");
      return null;
    } catch (e) {
      print("Error extracting Base64 image: $e");
      return null;
    }
  }

  void _showResultDialog(BuildContext context, String uploadedUrl,
      String ntuLevel, String? base64Image) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Determine the result image, text, and colors based on the NTU level
    String resultImage;
    String resultText;
    Color resultTextColor;
    List<Color> gradientColors;
    String turbidityText;

    // Assign values based on NTU level
    if (ntuLevel == 'NO_PAPERGLASS') {
      resultImage = 'assets/images/Not_found.png';
      resultText = 'Invalid Image!';
      resultTextColor = Colors.grey;
      gradientColors = const [Colors.grey, Colors.white];
      turbidityText = "There isn't paperglass with water in this photo";
    } else if (ntuLevel == 'WATER_NOT_DETECTED') {
      resultImage = 'assets/images/No_water.png';
      resultText = 'Water not detected!';
      resultTextColor = Colors.grey;
      gradientColors = const [Colors.grey, Colors.white];
      turbidityText = "Water clarity could not be determined";
    } else {
      double ntuValue = double.tryParse(ntuLevel) ?? 0;
      if (ntuValue > 5) {
        resultImage = 'assets/images/Bad_water.png';
        resultText = 'The water has a bad clearness!';
        resultTextColor = Colors.red;
        gradientColors = const [Colors.red, Colors.white];
      } else {
        resultImage = 'assets/images/Good_water.png';
        resultText = "The water has a good clearness!";
        resultTextColor = const Color(0xFF0083AB);
        gradientColors = const [Color(0xFF0083AB), Colors.white];
      }
      turbidityText = "The turbidity of the water is around $ntuLevel NTU";
    }

    // Decode the base64 image (if available)
    final imageBytes = base64Image != null ? base64Decode(base64Image) : null;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 8,
          child: StatefulBuilder(
            builder: (context, setState) {
              bool showImage = false;

              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: gradientColors,
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Water Clearness Result",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'RobotoCondensed',
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Display Result Image
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
                          width: screenWidth * 0.3,
                          height: screenWidth * 0.3,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Display Turbidity Text and Toggle Image Button
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
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'RobotoCondensed',
                              ),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              turbidityText,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontFamily: 'RobotoCondensed',
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Show/Hide Image Button
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  showImage = !showImage;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child:
                                  Text(showImage ? 'Hide Image' : 'Show Image'),
                            ),
                            if (showImage && imageBytes != null)
                              Column(
                                children: [
                                  const SizedBox(height: 20),
                                  Image.memory(
                                    imageBytes,
                                    width: screenWidth * 0.8,
                                    fit: BoxFit.contain,
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Exit Button
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _handleImageDeletion(context, uploadedUrl);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: resultTextColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
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
              );
            },
          ),
        );
      },
    );
  }
}
