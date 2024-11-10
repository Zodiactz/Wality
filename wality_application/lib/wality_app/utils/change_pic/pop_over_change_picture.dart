// pop_over_change_picture.dart
// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wality_application/wality_app/utils/navigator_utils.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import '../awesome_snack_bar.dart'; // Assuming the Snackbar utility is in this path

class PopOverChangePicture extends StatelessWidget {
  final Function(String) onImageUploaded; // Callback for image upload URL

  const PopOverChangePicture({super.key, required this.onImageUploaded});

  // Function to handle image selection and upload
  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      final File imageFile = File(image.path);
      onImageUploaded(imageFile.path); // Return the image file path to the parent
    } else {
      showAwesomeSnackBar(
        context,
        "No image",
       'No image selected',
        ContentType.warning,
      );
    }
    GoBack(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _pickImage(context, ImageSource.gallery),
          child: Container(
            height: 50,
            color: Colors.blue[500],
            child: const Center(
              child: Text(
                'From Gallery',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () => _pickImage(context, ImageSource.camera),
          child: Container(
            height: 50,
            color: Colors.blue[300],
            child: const Center(
              child: Text(
                'From Camera',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
