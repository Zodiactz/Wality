// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:popover/popover.dart';
import 'package:wality_application/wality_app/utils/pop_over_water.dart';

class CustomFloatingActionButton extends StatefulWidget {
  const CustomFloatingActionButton({super.key});

  @override
  _CustomFloatingActionButtonState createState() =>
      _CustomFloatingActionButtonState();
}

class _CustomFloatingActionButtonState
    extends State<CustomFloatingActionButton> {
  double _scale = 1.0;

  void _onPressed() {
    // Show the popup menu
    showPopover(
      context: context,
      bodyBuilder: (context) => const PopOverForWater(),
      width: 250,
      height: 100,
      backgroundColor: Colors.blue,
    );
  }

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _scale = 0.9; // Scale down when pressed
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _scale = 1.0; // Scale back to normal when released
    });
  }

  void _onTapCancel() {
    setState(() {
      _scale = 1.0; // Scale back to normal if the tap is canceled
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 100),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: _onPressed,
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.0),
          ),
          onPressed: () {
            showPopover(
                context: context,
                bodyBuilder: (context) => const PopOverForWater(),
                width: 250,
                height: 100,
                backgroundColor: Colors.blue);
          },
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
        ),
      ),
    );
  }
}
