import 'dart:io';
import 'package:flutter/material.dart';
import 'package:realm/realm.dart';
import 'package:wality_application/wality_app/repo/realm_service.dart';
import 'package:wality_application/wality_app/utils/change_pic/PictureCircle.dart';
import 'package:wality_application/wality_app/utils/navigator_utils.dart';
import 'package:wality_application/wality_app/utils/nav_bar/custom_bottom_navbar.dart';
import 'package:popover/popover.dart';
import 'package:wality_application/wality_app/utils/change_pic/pop_over_change_picture.dart';
import 'package:wality_application/wality_app/repo/user_service.dart';

class ChangePicAndUsernamePage extends StatefulWidget {
  const ChangePicAndUsernamePage({super.key});

  @override
  State<ChangePicAndUsernamePage> createState() =>
      _ChangePicAndUsernamePageState();
}

class _ChangePicAndUsernamePageState extends State<ChangePicAndUsernamePage> {
  final TextEditingController _usernameController = TextEditingController();
  final UserService _userService = UserService();
  String imgURL = "";
  final RealmService _realmService = RealmService();

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
                Picturecircle(),
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
                    // Collect the text from the TextFormField
                    final newUsername = _usernameController.text;

                    // Make sure the username isn't empty and the user is logged in
                    if (userId != null && newUsername.isNotEmpty) {
                      // Pass the new username to the update function
                      final result = await _userService.updateUsername(
                          userId, newUsername);

                      // Provide feedback to the user based on the result
                      if (result == null || result.contains('successfully')) {
                        openProfilePage(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(result)),
                        );
                      }
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}