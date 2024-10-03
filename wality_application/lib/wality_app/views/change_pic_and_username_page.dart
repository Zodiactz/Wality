import 'dart:io';
import 'package:flutter/material.dart';
import 'package:realm/realm.dart';
import 'package:wality_application/wality_app/repo/realm_service.dart';
import 'package:wality_application/wality_app/repo/user_service.dart';
import 'package:wality_application/wality_app/utils/change_pic/PictureCircle.dart';
import 'package:wality_application/wality_app/utils/navigator_utils.dart';
import 'package:wality_application/wality_app/views/waterCheck/qr_scanner_page.dart';

class ChangePicAndUsernamePage extends StatefulWidget {
  const ChangePicAndUsernamePage({super.key});

  @override
  State<ChangePicAndUsernamePage> createState() =>
      _ChangePicAndUsernamePageState();
}

class _ChangePicAndUsernamePageState extends State<ChangePicAndUsernamePage> {
  final TextEditingController _usernameController = TextEditingController();
  final UserService _userService = UserService();
  String imgURL = ""; // This will store the image path
  final RealmService _realmService = RealmService();

  @override
  void initState() {
    super.initState();
    _fetchCurrentUsername();
  }

  Future<void> _fetchCurrentUsername() async {
    final userId = _realmService.getCurrentUserId();
    if (userId != null) {
      // Fetch the current username from the user service
      final currentUsername = await _userService.fetchUsername(userId);
      setState(() {
        _usernameController.text =
            currentUsername ?? ''; // Set the current username as initial value
      });
    }
  }

  // Function to update the image URL when selected from Picturecircle
  void _updateImageURL(String path) {
    setState(() {
      imgURL = path; // Update imgURL with the selected image path
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 40),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0083AB),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: AppBar(
              backgroundColor: const Color(0xFF0083AB),
              elevation: 0,
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: const Icon(
                  Icons.chevron_left,
                  size: 32,
                ),
                onPressed: () {
                  GoBack(context);
                },
              ),
              title: const Padding(
                padding: EdgeInsets.only(right: 50),
                child: Center(
                  child: Text(
                    'Change info',
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'RobotoCondensed',
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFD6F1F3),
                  Color(0xFF0083AB),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.1, 1.0],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 180, left: 16, right: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Pass the callback to Picturecircle to get the image path
                Picturecircle(onImageUploaded: _updateImageURL), 
                const SizedBox(height: 20),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final userId = _realmService.getCurrentUserId();
                    final newUsername = _usernameController.text;

                    // Ensure the user is logged in and there is either a new username or image URL
                    if (userId != null &&
                        (newUsername.isNotEmpty || imgURL.isNotEmpty)) {
                      File? imageFile;

                      // Create a File object directly from the imgURL (the image path)
                      if (imgURL.isNotEmpty) {
                        try {
                          imageFile = File(imgURL);
                          if (!await imageFile.exists()) {
                            throw Exception('Image file does not exist.');
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: ${e.toString()}')),
                          );
                          return;
                        }
                      }

                      try {
                        // Call the updateUserProfile function with userId, imageFile, and newUsername
                        final result = await _userService.updateUserProfile(
                            userId, imageFile, newUsername);

                        // Provide feedback to the user based on the result
                        if (result == null || result.contains('successfully')) {
                          openProfilePage(
                              context); // Navigate to the profile page upon success
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(result)),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${e.toString()}')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Please provide a username or upload an image.')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF342056),
                    fixedSize: const Size(300, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Change',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'RobotoCondensed',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
