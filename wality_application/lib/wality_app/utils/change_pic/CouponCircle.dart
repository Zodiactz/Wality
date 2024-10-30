// ignore_for_file: library_private_types_in_public_api, file_names

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:popover/popover.dart';
import 'package:wality_application/wality_app/utils/change_pic/pop_over_change_picture.dart';

class CouponCircle extends StatefulWidget {
  const CouponCircle({super.key, required this.onImageUploaded});

  final Function(String)
      onImageUploaded; // Callback to return the coupon image path

  @override
  _CouponCircleState createState() => _CouponCircleState();
}

class _CouponCircleState extends State<CouponCircle> {
  File? selectedCouponImage; // Stores the chosen image as a File object

  // Function to handle the image when a user selects it
  void _onCouponImageSelected(String path) {
    setState(() {
      selectedCouponImage = File(path); // Update with the selected image file
    });
    widget.onImageUploaded(
        path); // Call the callback with the selected image path
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // Show the popup for selecting a coupon image
        showPopover(
          context: context,
          bodyBuilder: (context) =>
              PopOverChangePicture(onImageUploaded: _onCouponImageSelected),
          width: 250,
          height: 100,
          backgroundColor: Colors.green,
        );
      },
      child: ClipOval(
        child: selectedCouponImage != null
            ? Image.file(
                selectedCouponImage!, // Display selected image
                width: 96,
                height: 96,
                fit: BoxFit.cover,
              )
            : Container(
                width: 96,
                height: 96,
                color: Colors.grey[200],
                child: const Icon(
                  Icons.add_a_photo, // Default icon for no image
                  color: Colors.grey,
                  size: 48,
                ),
              ),
      ),
    );
  }
}
