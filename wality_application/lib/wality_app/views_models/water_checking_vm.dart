import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:tflite_v2/tflite_v2.dart';
import 'package:wality_application/wality_app/models/waterquality.dart';

class WaterCheckingViewModel extends ChangeNotifier {
  File image;
  List<WaterQualityRecognition> recognitions = [];
  String filteredResults = "";
  bool _isLoading = false;

  WaterCheckingViewModel(this.image) {}

  bool get isLoading => _isLoading;
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        image = File(pickedFile.path);
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Error picking image: $e');
    }
  }
}
