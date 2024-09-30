import 'package:flutter/material.dart';
import 'package:popover/popover.dart';
import 'package:wality_application/wality_app/utils/change_pic/pop_over_change_picture.dart';
import 'package:wality_application/wality_app/utils/pop_over_water.dart';

class Picturecircle extends StatelessWidget {
  const Picturecircle({super.key});
  @override
  Widget build(BuildContext context) {
    String imgURL = "";
    return GestureDetector(
      onTap: () async {
        // Show the popup menu
        showPopover(
            context: context,
            bodyBuilder: (context) => PopOverChangePicture(
              onImageSelected: (String imageUrl) {
                // Handle the image selection
                imgURL = imageUrl;
              },
            ),
            width: 250,
            height: 100,
            backgroundColor: Colors.blue);
      },
      child: ClipOval(
        child: imgURL.isNotEmpty
            ? Image.network(
                imgURL,
                width: 96,
                height: 96,
                fit: BoxFit.cover,
              )
            : Image.asset(
                'assets/images/cat.jpg',
                width: 96,
                height: 96,
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}
