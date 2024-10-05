import 'dart:math';
import 'package:wality_application/wality_app/models/water.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:realm/realm.dart';
import 'package:wality_application/wality_app/utils/constant.dart';

final App app = App(AppConfiguration('wality-1-djgtexn'));
final userid = app.currentUser?.id;

class WaterSaveViewModel extends ChangeNotifier {
  final Water _water = Water(mlSaved: 0, savedCount: 0, maxMl: 550);

  Water get water => _water;

 WaterSaveViewModel() {
  final currentUserId = app.currentUser?.id;
  print("WaterSaveViewModel initialized for user: $currentUserId");
  fetchInitialData();
}

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

  Future<void> fetchInitialData() async {
    final userId = app.currentUser?.id;
    print("Fetching data for user: $userId");

    if (userId == null) {
      print("No user ID found, resetting data.");
      resetData(); // Reset data if no user is logged in
      return;
    }

    try {
      final response = await http.get(Uri.parse('$baseUrl/userId/$userId'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print("Data fetched for user: $userId - $data");

        setMlSaved(data['currentMl'] ?? 0);
        setSavedCount(data['botLiv'] ?? 0);
      } else {
        print(
            "Error fetching data for user: $userId - Status Code: ${response.statusCode}");
        resetData(); // Reset to default if there's an error
      }
    } catch (e) {
      print('Error fetching initial data for user: $userId - $e');
      resetData(); // Reset data on error
    }
  }

  void resetData() {
    print("Resetting water data");
    _water.mlSaved = 0;
    _water.savedCount = 0;
    _water.maxMl = 550;
    notifyListeners();
    print(
        "Water data after reset: mlSaved=${_water.mlSaved}, savedCount=${_water.savedCount}");
  }

  Future<void> refreshData() async {
    await fetchInitialData();
    notifyListeners(); // Notify listeners to refresh the UI
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
            sin((i / size.width * 2 * pi) + (animationValue * 2 * pi) + pi) *
                10,
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
