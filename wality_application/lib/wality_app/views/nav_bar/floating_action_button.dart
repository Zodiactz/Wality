import 'package:flutter/material.dart';
import 'package:popover/popover.dart';
import 'package:wality_application/wality_app/utils/navigator_utils.dart';
import 'package:wality_application/wality_app/utils/pop_over.dart';

class CustomFloatingActionButton extends StatelessWidget {
  const CustomFloatingActionButton({super.key});
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        // Show the popup menu
        showPopover(
            context: context,
            bodyBuilder: (context) => PopOver(),
            width: 250,
            height: 100,
            backgroundColor: Colors.blue);
      },
      backgroundColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
      ),
      child: Container(
        height: 100,
        width: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50.0),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF26CBFF),
              Color(0xFF6980FD),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const Icon(Icons.water_drop, color: Colors.black, size: 40),
      ),
    );
  }
}
