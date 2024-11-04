// ignore_for_file: library_private_types_in_public_api, file_names

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:popover/popover.dart';
import 'package:wality_application/wality_app/repo/realm_service.dart';
import 'package:wality_application/wality_app/repo/user_service.dart';
import 'package:wality_application/wality_app/utils/change_pic/pop_over_change_picture.dart';

class Picturecircle extends StatefulWidget {
  const Picturecircle({super.key, required this.onImageUploaded});

  final Function(String) onImageUploaded; // Callback to return the image path

  @override
  _PicturecircleState createState() => _PicturecircleState();
}

class _PicturecircleState extends State<Picturecircle> {
  String? imgURL; // For storing the uploaded image URL (nullable)
  final UserService _userService = UserService();
  final RealmService _realmService = RealmService();

  @override
  void initState() {
    super.initState();
    final userId = _realmService.getCurrentUserId();
    if (userId != null) {
      // Fetch and set the current user's image URL
      _userService.fetchUserImage(userId).then((value) {
        setState(() {
          imgURL = value ?? ''; // Use default if no URL is found
        });
      });
    }
  }

  // Function to handle the image URL when an image is uploaded
  void _onImageUploaded(String url) {
    setState(() {
      imgURL = url; // Update the imgURL with the new image URL
    });
    widget.onImageUploaded(url); // Call the callback with the new image URL
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // Show the popup for selecting a picture
        showPopover(
          context: context,
          bodyBuilder: (context) =>
              PopOverChangePicture(onImageUploaded: _onImageUploaded),
          width: 250,
          height: 100,
          backgroundColor: Colors.blue,
        );
      },
      child: ClipOval(
        child: imgURL != null && imgURL!.isNotEmpty
            ? (imgURL!.startsWith('http')
                ? Image.network(
                    imgURL!,
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                  )
                : Image.file(
                    File(imgURL!), // Use Image.file for local files
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                  ))
            : Image.asset(
                'assets/images/cat.png',
                width: 96,
                height: 96,
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}
