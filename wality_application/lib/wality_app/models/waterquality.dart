class WaterQualityRecognition {
  final String label;
  final double confidence;
  final double? x;
  final double? y;
  final double? w;
  final double? h;

  WaterQualityRecognition({
    required this.label,
    required this.confidence,
    this.x,
    this.y,
    this.w,
    this.h,
  });
}
