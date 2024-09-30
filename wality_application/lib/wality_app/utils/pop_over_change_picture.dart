import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PopOverChangePicture extends StatelessWidget {
  final Function(String) onImageSelected;  // Callback for image selection

  const PopOverChangePicture({super.key, required this.onImageSelected});

  Future<void> _pickImageFromGallery(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // Notify the parent widget of the new image
      onImageSelected(image.path);
      Navigator.of(context).pop();  // Close the popover after selection
    }
  }

  Future<void> _pickImageFromCamera(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      // Notify the parent widget of the new image
      onImageSelected(image.path);
      Navigator.of(context).pop();  // Close the popover after selection
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
                  color: Colors.white, // Text color
                  fontSize: 16, // Font size
                  fontWeight: FontWeight.bold, // Font weight
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
