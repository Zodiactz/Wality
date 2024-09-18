import 'package:provider/provider.dart';
import 'package:wality_application/wality_app/views_models/water_save_vm.dart';
import 'package:flutter/material.dart';

class WaterService {
  Future<void> refreshData(WaterSaveViewModel waterSaveVM) async {
    await waterSaveVM.refreshData(); // Fetch updated data
  }

  // New method to handle the state and refresh logic
  Future<void> refreshWaterDataWithState(BuildContext context, Function setState) async {
    final waterSaveVM = Provider.of<WaterSaveViewModel>(context, listen: false);
    await refreshData(waterSaveVM); // Use the existing refreshData method
    setState(); // Update the state in the UI
  }
}
