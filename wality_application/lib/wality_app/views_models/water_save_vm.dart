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
  fetchInitialData();
}

  void addWater(int ml) {
    _water.mlSaved += ml;
    checkAndIncrementSavedCount();
  }

  void setMaxMl(int maxMl) {
    _water.maxMl = maxMl;
  }

  void setMlSaved(int mlSaved) {
    _water.mlSaved = mlSaved;
  }

  void setSavedCount(int savedCount) {
    _water.savedCount = savedCount;
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

    if (userId == null) {
      resetData(); // Reset data if no user is logged in
      return;
    }

    try {
      final response = await http.get(Uri.parse('$baseUrl/userId/$userId'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        setMlSaved(data['currentMl'] ?? 0);
        setSavedCount(data['botLiv'] ?? 0);
      } else {
        resetData(); // Reset to default if there's an error
      }
    } catch (e) {
      resetData(); 
      throw Exception('Error fetching initial data for user: $userId - $e');
      // Reset data on error
    }
  }

void resetData() {
  
  // Use addPostFrameCallback to schedule this action after the current build phase
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _water.mlSaved = 0;
    _water.savedCount = 0;
    _water.maxMl = 550;
    notifyListeners();

  });
}

  Future<void> refreshData() async {
    await fetchInitialData();
  }
}

