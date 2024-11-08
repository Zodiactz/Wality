import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wality_application/wality_app/utils/navigator_utils.dart';
import 'package:wality_application/wality_app/views/waterCheck/ntu_checking_page.dart';

class PopOverForWater extends StatelessWidget {
  const PopOverForWater({super.key});

  Future<bool> _shouldShowTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool('water_tutorial_seen') ?? false);
  }

  void _showTutorial(BuildContext context) async {
    if (await _shouldShowTutorial()) {
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => WaterTutorialPopup(
            onComplete: () {
              Navigator.pop(context);
              openWaterCheckingPage(context);
            },
          ),
        );
      }
    } else {
      openWaterCheckingPage(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _showTutorial(context),
          child: Container(
            height: 50,
            color: Colors.blue[500],
            child: const Center(
              child: Text(
                'Water Clearness Reader',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'RobotoCondensed',
                ),
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Future.delayed(
              const Duration(),
              () => openQRcodePage(context),
            );
          },
          child: Container(
            height: 50,
            color: Colors.blue[300],
            child: const Center(
              child: Text(
                'QR Collect Scanner',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'RobotoCondensed',
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}