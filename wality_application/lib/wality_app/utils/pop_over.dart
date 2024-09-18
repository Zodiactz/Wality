import 'package:flutter/material.dart';
import 'package:wality_application/wality_app/utils/navigator_utils.dart';

class PopOver extends StatelessWidget {
  const PopOver({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Future.delayed(
              const Duration(),
              () => openWaterCheckingPage(
                  context), // Replace with camera function
            );
          },
          child: Container(
            height: 50,
            color: Colors.blue[500],
            child: const Center(
              child: Text(
                'water checking',
                style: TextStyle(
                  color: Colors.white, // Text color
                  fontSize: 16, // Font size
                  fontWeight: FontWeight.bold, // Font weight
                ),
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Future.delayed(
              const Duration(),
              () => openQRcodePage(
                  context), // Replace with camera function
            );
          },
          child: Container(
            height: 50,
            color: Colors.blue[300],
            child: const Center(
              child: Text(
                'QR code scanner',
                style: TextStyle(
                  color: Colors.white, // Text color
                  fontSize: 16, // Font size
                  fontWeight: FontWeight.bold, // Font weight
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
