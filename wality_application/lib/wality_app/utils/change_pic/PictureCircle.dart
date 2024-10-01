import 'dart:io';

import 'package:flutter/material.dart';
import 'package:popover/popover.dart';
import 'package:wality_application/wality_app/repo/realm_service.dart';
import 'package:wality_application/wality_app/repo/user_service.dart';
import 'package:wality_application/wality_app/utils/change_pic/pop_over_change_picture.dart';

class Picturecircle extends StatefulWidget {
  const Picturecircle({super.key, required Null Function(dynamic url) onImageUploaded});

  @override
  _PicturecircleState createState() => _PicturecircleState();
}

class _PicturecircleState extends State<Picturecircle> {
  String imgURL = "";  // For storing the uploaded image URL
  final UserService _userService = UserService();
  final RealmService _realmService = RealmService();

  @override
  void initState() {
    super.initState();
    final userId = _realmService.getCurrentUserId();
    if (userId != null) {
      // Fetch and set the current user's image URL
      _userService.fetchUserImage(userId!).then((value) {
        setState(() {
          imgURL = value ?? '';  // Use default if no URL is found
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // Show the popup for selecting a picture
        showPopover(
          context: context,
          bodyBuilder: (context) => PopOverChangePicture(
            onImageUploaded: (url) {
              setState(() {
                imgURL = url;  // Update the image URL
              });
            },
          ),
          width: 250,
          height: 100,
          backgroundColor: Colors.blue,
        );
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
