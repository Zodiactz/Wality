// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';
import 'package:wality_application/wality_app/repo/auth_service.dart';
import 'package:wality_application/wality_app/views/authen/logo_page.dart';
import 'package:wality_application/wality_app/views/main_page.dart';
import 'package:wality_application/wality_app/views/waterCheck/ntu_checking_page.dart';
import 'package:wality_application/wality_app/views_models/water_save_vm.dart';

final App app = App(AppConfiguration('wality-1-djgtexn'));
final authService = AuthService();

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
  Navigator.pushNamed(context, '/mainpage');
}

void openProfilePage(BuildContext context) {
  Navigator.pushReplacementNamed(context, '/mainpage',
      arguments: {'initialPage': 'profile'});
}

void openSettingPage(BuildContext context) async {
  Navigator.pushNamed(context, '/settingpage');
}

void openSummaryGraphPage(BuildContext context) async {
  Navigator.pushNamed(context, '/summarygraphpage');
}

void openChoosechangePage(BuildContext context) async {
  Navigator.pushNamed(context, '/choosechange');
}

void openRewardPage(BuildContext context) async {
  Navigator.pushNamed(context, '/rewardpage');
}

void openRankingPage(BuildContext context) async {
  Navigator.pushNamed(context, '/rankingpage');
}

void openAdminPage(BuildContext context) async {
  Navigator.pushNamed(context, '/adminpage');
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

void openQRcodePage(BuildContext context) async {
  await Navigator.pushNamed(context, '/qrscanner');
}

void openChangeMail(BuildContext context) async {
  Navigator.pushNamed(context, '/changeMail');
}

void openChangePass(BuildContext context) async {
  Navigator.pushNamed(context, '/changePass');
}

void LogOutToOutsite(BuildContext context) async {
  try {
    await app.currentUser?.logOut(); // Log the user out
    await authService.deleteCacheDir(); // Delete cached data
    await authService.deleteAppDir(); // Delete app data

    // Clear WaterSaveViewModel data
    final waterSaveVM =
        Provider.of<WaterSaveViewModel>(context, listen: false);
    waterSaveVM
        .resetData(); // Reset water data to ensure old values are cleared

    // Restart app or navigate to login
    restartApp(context); // Navigate to a new instance of your app
  } catch (e) {
    throw Exception(e);
  }
}

void restartApp(BuildContext context) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
              create: (_) =>
                  WaterSaveViewModel(), // New instance of WaterSaveViewModel
              child: const LogoPage(), // Login screen
            )),
    (Route<dynamic> route) => false, // Remove all previous routes
  );
}

void GoBack(BuildContext context) async {
  Navigator.of(context).pop();
}

void ConfirmAtWaterChecking(BuildContext context) async {
  Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MainPage()),
      (Route<dynamic> route) => false);
}

void OpenChangePictureAndUsernamePage(BuildContext context) async {
  Navigator.pushNamed(context, '/changePicAndUsernamePage');
}

void OpenAdminPage(BuildContext context) async {
  Navigator.pushNamed(context, '/adminpage');
}

void OpenResetPasswordPage(BuildContext context) async {
  Navigator.pushNamed(context, '/resetpass');
}
