import 'dart:convert';
import 'package:http/http.dart' as http;

class Prediction {
  final int width;
  final int height;
  final double x;
  final double y;
  final double confidence;
  final int classId;
  final String className;
  final String detectionId;
  final String parentId;

  Prediction({
    required this.width,
    required this.height,
    required this.x,
    required this.y,
    required this.confidence,
    required this.classId,
    required this.className,
    required this.detectionId,
    required this.parentId,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      width: json['width'],
      height: json['height'],
      x: json['x'],
      y: json['y'],
      confidence: json['confidence'],
      classId: json['class_id'],
      className: json['class'],
      detectionId: json['detection_id'],
      parentId: json['parent_id'],
    );
  }
}