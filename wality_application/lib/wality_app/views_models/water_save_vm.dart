import 'dart:math';
import 'package:wality_application/wality_app/models/water.dart';
import 'package:flutter/material.dart';

class WaterSaveViewModel extends ChangeNotifier {
  final Water _water = Water(mlSaved: 0,savedCount: 0, maxMl: 550);

  Water get water => _water;

  void addWater(int ml) {
    _water.mlSaved += ml;
    checkAndIncrementSavedCount();
    notifyListeners();
  }

  void setMaxMl(int maxMl) {
    _water.maxMl = maxMl;
    notifyListeners();
  }

  void setMlSaved(int mlSaved) {
    _water.mlSaved = mlSaved;
    notifyListeners();
  }

  void setSavedCount(int savedCount) {
    _water.savedCount = savedCount;
    notifyListeners();
  }

  void checkAndIncrementSavedCount() {
    if (_water.mlSaved >= _water.maxMl) {
      _water.savedCount += 1;
      _water.mlSaved = 0;
    }
  }

  double getFillRatio() {
    return min(water.mlSaved / water.maxMl, 1.0);
  }
}

class WavePainter extends CustomPainter {
  final double animationValue;
  final double fillRatio;

  WavePainter(this.animationValue, this.fillRatio);
  
  @override
  void paint(Canvas canvas, Size size) {
    double waveHeight = size.height * fillRatio;
    Paint paint = Paint()
      ..color = const Color(0xFF4FC3F7).withOpacity(0.6)
      ..style = PaintingStyle.fill;

    Path path = Path();
    for (double i = 0; i <= size.width; i++) {
      path.lineTo(
        i,
        size.height -
            waveHeight -
            sin((i / size.width * 2 * pi) + (animationValue * 2 * pi)) * 10,
      );
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    paint.color = const Color(0xFF0288D1).withOpacity(0.6);
    path = Path();
    for (double i = 0; i <= size.width; i++) {
      path.lineTo(
        i,
        size.height -
            waveHeight -
            sin((i / size.width * 2 * pi) + (animationValue * 2 * pi) + pi) * 10,
      );
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}



