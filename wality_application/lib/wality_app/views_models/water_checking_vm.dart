import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_v2/tflite_v2.dart';
import 'package:wality_application/wality_app/models/waterquality.dart';

class WaterCheckingViewModel extends ChangeNotifier {
  File image;
  List<WaterQualityRecognition> recognitions = [];
  String filteredResults = "";
  String waterClarityStatus = "";
  String turbidityLevel = "around 0";
  String accuracy = "0%";
  bool isGoodWater = false;

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
    var recognitionsList = await Tflite.detectObjectOnImage(
      path: image.path,
      model: "YOLO",
      threshold: 0.05,
      imageMean: 127.5,
      imageStd: 127.5,
      asynch: true,
    );

    recognitions = recognitionsList?.map((recognition) {
      return WaterQualityRecognition(
        label: recognition['detectedClass'],
        confidence: recognition['confidenceInClass'],
        x: recognition['rect']['x'],
        y: recognition['rect']['y'],
        w: recognition['rect']['w'],
        h: recognition['rect']['h'],
      );
    }).toList() ?? [];

    // Filter and interpret results
    filteredResults = recognitions
        .where((recognition) => recognition.confidence! > 0.7)
        .map((recognition) =>
            "${recognition.label}: ${(recognition.confidence! * 100).toStringAsFixed(2)}% (x: ${recognition.x}, y: ${recognition.y})")
        .join("\n");

    interpretResults();

    notifyListeners();
  }

  void interpretResults() {
    bool detectedPaperGlass = recognitions.any((r) => r.label == 'Paper_Glass');
    WaterQualityRecognition? ntuRecognition = recognitions.firstWhere(
      (r) => r.label.startsWith('NTU_'),
      orElse: () => WaterQualityRecognition(label: '', confidence: 0.0),
    );

    if (ntuRecognition != null && ntuRecognition.label.isNotEmpty) {
      int ntuValue = int.parse(ntuRecognition.label.split('_')[1]);
      turbidityLevel = "around $ntuValue";
      accuracy = "${(ntuRecognition.confidence! * 100).toStringAsFixed(2)}%";
      
      // Update clarity and icon based on NTU and paper detection
      if (detectedPaperGlass && ntuValue >= 0 && ntuValue <= 5) {
        isGoodWater = true;
        waterClarityStatus = "The Water has a good clearness!";
      } else if (detectedPaperGlass && ntuValue > 5 && ntuValue <= 20) {
        isGoodWater = false;
        waterClarityStatus = "The Water is not clear enough!";
      } else if (detectedPaperGlass && ntuValue == 0) {
        waterClarityStatus = "Empty Paper Glass Detected";
      }
    } else {
      turbidityLevel = "No NTU detected";
      waterClarityStatus = detectedPaperGlass ? "Empty Paper Glass Detected" : "No Water Detected";
    }
  }

  // Getter to check if Paper Glass is detected
  bool get isPaperGlassDetected {
    return recognitions.any((recognition) => recognition.label == 'Paper_Glass');
  }

  // Getter to check if Water (NTU) is detected
  bool get isWaterDetected {
    return recognitions.any((recognition) => recognition.label.startsWith('NTU_'));
  }
}
