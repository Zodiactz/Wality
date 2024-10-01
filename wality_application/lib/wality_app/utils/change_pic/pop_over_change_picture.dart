import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wality_application/wality_app/repo/user_service.dart';

class PopOverChangePicture extends StatelessWidget {
  final Function(String) onImageUploaded;  // Callback for image upload URL

  const PopOverChangePicture({super.key, required this.onImageUploaded});

   // Function to upload the selected image
  Future<void> _handleImageUpload(BuildContext context, XFile image) async {
    final userService = UserService();  // Instance of your UserService
    final File imageFile = File(image.path);

    // Print message before upload starts
    print('Uploading image: ${imageFile.path}');

    String? uploadedImageUrl = await userService.uploadImage(imageFile);

    // Print message after upload completes
    if (uploadedImageUrl != null) {
      print('Image uploaded successfully. URL: $uploadedImageUrl');
      onImageUploaded(uploadedImageUrl);  // Return uploaded image URL to parent
    } else {
      print('Failed to upload image');
      // Handle upload failure (optional)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload image')),
      );
    }

    Navigator.of(context).pop();  // Close the popover after uploading
  }

  // Function to pick an image from the gallery and upload it
  Future<void> _pickImageFromGallery(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      await _handleImageUpload(context, image);  // Upload image
    }
  }

  // Function to pick an image from the camera and upload it
  Future<void> _pickImageFromCamera(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      await _handleImageUpload(context, image);  // Upload image
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _pickImageFromGallery(context),
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
          onTap: () => _pickImageFromCamera(context),
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
