import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:wality_application/wality_app/utils/constant.dart';
import 'package:wality_application/wality_app/views_models/water_save_vm.dart';
import 'package:flutter/material.dart';

class WaterService {
  Future<void> refreshData(WaterSaveViewModel waterSaveVM) async {
    await waterSaveVM.refreshData(); // Fetch updated data
  }

  // New method to handle the state and refresh logic
  Future<void> refreshWaterDataWithState(
      BuildContext context, Function setState) async {
    final waterSaveVM = Provider.of<WaterSaveViewModel>(context, listen: false);
    await refreshData(waterSaveVM); // Use the existing refreshData method
    setState(); // Update the state in the UI
  }

  Future<bool> updateUserWater(
      String userId,
      int currentMl,
      int botLiv,
      int totalMl,
      int limit,
      int eBot,
      int dBot,
      int mBot,
      int yBot) async {
    final uri = Uri.parse('$baseUrl/updateUserWater/$userId');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'currentMl': currentMl,
      'botLiv': botLiv,
      'totalMl': totalMl,
      'fillingLimit': limit,
      'eventBot': eBot,
      'dayBot': dBot,
      'monthBot': mBot,
      'yearBot': yBot,
    });

    try {
      final response = await http.post(uri, headers: headers, body: body);
      return response.statusCode == 200;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<bool> updateWaterStatus(String waterId, String status) async {
    final uri = Uri.parse('$baseUrl/updateWaterStatus/$waterId');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'status': status});

    try {
      final response = await http.post(uri, headers: headers, body: body);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<int?> fetchWaterId(String waterId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/waterId/$waterId'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['quantity'];
      }
    } catch (e) {
      throw Exception('Error fetching waterId: $e');
    }
    return null;
  }
}
