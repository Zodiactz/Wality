import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:wality_application/wality_app/views/home_page.dart';
import 'package:wality_application/wality_app/views/water_checking_page.dart';
import 'package:wality_application/wality_app/views_models/profile_vm.dart';

void openChoosewayPageFromLogoPage(BuildContext context) async {
  Future.delayed(const Duration(seconds: 5), () {
    Navigator.pushNamed(context, '/choosewaypage');
  });
}

void openChoosewayPage(BuildContext context) async {
  Navigator.pushNamed(context, '/choosewaypage');
}

void openSignInPage(BuildContext context) async {
  Navigator.pushNamed(context, '/signinpage');
}

void openSignUpPage(BuildContext context) async {
  Navigator.pushNamed(context, '/signuppage');
}

void openForgotPassword(BuildContext context) async {
  Navigator.pushNamed(context, '/forgetpasswordpage');
}

void openHomePage(BuildContext context) async {
  Navigator.pushNamed(context, '/homepage');
}

void openProfilePage(BuildContext context) async {
  Navigator.pushNamed(context, '/profilepage');
}

void openSettingPage(BuildContext context) async {
  Navigator.pushNamed(context, '/settingpage');
}

void openSummaryGraphPage(BuildContext context) async {
  Navigator.pushNamed(context, '/summarygraphpage');
}

void openWaterCheckingPage(BuildContext context) async {
  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: ImageSource.camera);
  if (image != null) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WaterCheckingPage(image: File(image.path)),
      ),
    );
  }
}

void openChangeInfoPage(BuildContext context) async {
  Navigator.pushNamed(context, '/changeinfopage');
}

void LogOutToOutsite(BuildContext context) async {
  final profilevm = Provider.of<ProfileViewModel>(context, listen: false);
  //await profilevm.signOut();
  Navigator.of(context).pushReplacementNamed('/logopage');
}

void GoBack(BuildContext context) async {
  Navigator.of(context).pop();
}

void ConfirmAtWaterChecking(BuildContext context) async {
                                        Navigator.of(context)
                                            .pushAndRemoveUntil(
                                                MaterialPageRoute(
                                                    builder:
                                                        (context) =>
                                                            const HomePage()),
                                                (Route<dynamic> route) =>
                                                    false);
                                      }
