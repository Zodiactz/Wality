// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wality_application/wality_app/repo/realm_service.dart';
import 'package:wality_application/wality_app/repo/reward_service.dart';
import 'package:wality_application/wality_app/repo/user_service.dart';
import 'package:wality_application/wality_app/utils/awesome_snack_bar.dart';
import 'package:wality_application/wality_app/utils/change_pic/PictureCircle.dart';
import 'package:wality_application/wality_app/utils/navigator_utils.dart';
import 'package:wality_application/wality_app/utils/text_form_field_authen.dart';
import 'package:wality_application/wality_app/views_models/authentication_vm.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class ChangePicAndUsernamePage extends StatefulWidget {
  const ChangePicAndUsernamePage({super.key});

  @override
  State<ChangePicAndUsernamePage> createState() =>
      _ChangePicAndUsernamePageState();
}

class _ChangePicAndUsernamePageState extends State<ChangePicAndUsernamePage> {
  final TextEditingController usernameController = TextEditingController();
  final UserService _userService = UserService();
  String imgURL = "";
  final RealmService _realmService = RealmService();
  bool _mounted = true;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUsername();
  }

  @override
  void dispose() {
    _mounted = false;
    usernameController.dispose();
    super.dispose();
  }

  Future<void> _fetchCurrentUsername() async {
    if (!mounted) return;

    final userId = _realmService.getCurrentUserId();
    if (userId != null) {
      final currentUsername = await _userService.fetchUsername(userId);
      if (_mounted) {
        setState(() {
          usernameController.text = currentUsername ?? '';
        });
      }
    }
  }

  void _updateImageURL(String path) {
    if (_mounted) {
      setState(() {
        imgURL = path;
      });
    }
  }

  Future<void> _handleProfileUpdate(AuthenticationViewModel authvm) async {
    if (!mounted) return;

    final userId = _realmService.getCurrentUserId();
    final newUsername = usernameController.text;

    // Clear previous errors
    authvm.clearErrors();
    authvm.setUsernameError(null);

    // Validate username
    final usernameError = authvm.validateUsername(newUsername);
    if (usernameError != null) {
      if (_mounted) {
        authvm.setUsernameError(usernameError);
        showAwesomeSnackBar(
          context,
          "Error",
          usernameError,
          ContentType.failure,
        );
      }
      return;
    }

    if (userId != null && (newUsername.isNotEmpty || imgURL.isNotEmpty)) {
      File? imageFile;

      if (imgURL.isNotEmpty) {
        try {
          imageFile = File(imgURL);
          if (!await imageFile.exists()) {
            throw Exception('Image file does not exist.');
          }
        } catch (e) {
          if (_mounted) {
            showAwesomeSnackBar(
              context,
              'Error',
              e.toString(),
              ContentType.failure,
            );
          }
          return;
        }
      }

      try {
        final result = await _userService.updateUserProfile(
            userId, imageFile, newUsername);

        if (!_mounted) return;

        if (result == null || result.contains('successfully')) {
          openProfilePage(context);
        } else {
          authvm.setUsernameError('Failed to update profile');
          showAwesomeSnackBar(
            context,
            "Error",
            "Failed to update profile",
            ContentType.failure,
          );
        }
      } catch (e) {
        if (_mounted) {
          authvm.setUsernameError('An error occurred while updating profile');
          showAwesomeSnackBar(
            context,
            "Error",
            "An error occurred while updating profile",
            ContentType.failure,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthenticationViewModel>(
      builder: (context, authvm, child) {
        return Scaffold(
          extendBody: true,
          extendBodyBehindAppBar: true,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight + 40),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF0083AB),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  leading: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 30,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      GoBack(context);
                    },
                  ),
                  title: const Padding(
                    padding: EdgeInsets.only(right: 50),
                    child: Center(
                      child: Text(
                        'Update Profile',
                        style: TextStyle(
                          fontSize: 26,
                          fontFamily: 'Roboto',
                          color: Colors.white,
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
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Picturecircle(onImageUploaded: _updateImageURL);
                          },
                          child:
                              Picturecircle(onImageUploaded: _updateImageURL),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              Picturecircle(onImageUploaded: _updateImageURL);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.blueAccent.withOpacity(0.8),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextFormFieldAuthen(
                      controller: usernameController,
                      hintText: "New Username",
                      obscureText: false,
                      focusNode: FocusNode(),
                      borderColor: authvm.usernameError != null
                          ? Colors.red
                          : Colors.grey,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () => _handleProfileUpdate(authvm),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0083AB),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 60),
                      ),
                      child: const Text(
                        'Update',
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Roboto',
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
      },
    );
  }
}
