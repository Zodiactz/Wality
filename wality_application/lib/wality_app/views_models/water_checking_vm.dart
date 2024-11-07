import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_v2/tflite_v2.dart';
import 'package:wality_application/wality_app/models/waterquality.dart';

class WaterCheckingViewModel extends ChangeNotifier {
  File image;
  List<WaterQualityRecognition> recognitions = [];
  String filteredResults = "";

  WaterCheckingViewModel(this.image) {
    _loadModel();
    detectImage(image);
  }

  Future<void> _loadModel() async {
    await Tflite.loadModel(
      model: "assets/model/best_float32.tflite",
      labels: "assets/model/label.txt",  // Updated to reflect new labels source
    );
  }

  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        image = File(pickedFile.path);
        detectImage(image);
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Error picking image: $e');
    }
  }

  Future<void> detectImage(File image) async {
    var recognitionsList = await Tflite.detectObjectOnImage(  // Updated to use object detection
      path: image.path,
      model: "YOLO",
      threshold: 0.05,
      imageMean: 127.5,
      imageStd: 127.5,
      asynch: true,
    );

    recognitions = recognitionsList?.map((recognition) {
      return WaterQualityRecognition(
        label: recognition['detectedClass'],  // Using detected object class
        confidence: recognition['confidenceInClass'],
        x: recognition['rect']['x'],  // Coordinates of detected object
        y: recognition['rect']['y'],
        w: recognition['rect']['w'],
        h: recognition['rect']['h'],
      );
    }).toList() ?? [];

    filteredResults = recognitions
        .where((recognition) => recognition.confidence! > 0.7)
        .map((recognition) =>
            "${recognition.label}: ${(recognition.confidence! * 100).toStringAsFixed(2)}% (x: ${recognition.x}, y: ${recognition.y})")
        .join("\n");

    if (filteredResults.isEmpty) {
      filteredResults = "No results above 70% confidence";
    }

    notifyListeners();
  }
}
