import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';
import 'package:wality_application/main.dart';
import 'package:wality_application/wality_app/repo/auth_service.dart';
import 'package:wality_application/wality_app/utils/navigator_utils.dart';
import 'package:wality_application/wality_app/views/authen/logo_page.dart';
import 'package:wality_application/wality_app/views_models/profile_vm.dart';
import 'package:wality_application/wality_app/views_models/water_save_vm.dart';

class SettingPage extends StatelessWidget {
  SettingPage({super.key});
  final App app = App(AppConfiguration('wality-1-djgtexn'));
  final authService = AuthService();

  void logoutFromApp(BuildContext context) async {
    try {
      final currentUserId = app.currentUser?.id;
      print("Logging out user: $currentUserId");

      await app.currentUser?.logOut(); // Log the user out
      await authService.deleteCacheDir(); // Delete cached data
      await authService.deleteAppDir(); // Delete app data

      // Clear WaterSaveViewModel data
      final waterSaveVM =
          Provider.of<WaterSaveViewModel>(context, listen: false);
      waterSaveVM
          .resetData(); // Reset water data to ensure old values are cleared
      print("Water data reset for user: $currentUserId");

      // Restart app or navigate to login
      restartApp(context); // Navigate to a new instance of your app
    } catch (e) {
      print("Error during logout: $e");
    }
  }

  void restartApp(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider(
                create: (_) =>
                    WaterSaveViewModel(), // New instance of WaterSaveViewModel
                child: LogoPage(), // Login screen
              )),
      (Route<dynamic> route) => false, // Remove all previous routes
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewModel>(builder: (context, profilevm, child) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              child: Container(
                width: double.maxFinite,
                height: 180,
                decoration: const BoxDecoration(
                  color: Color(0xFF0083AB),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.chevron_left,
                          size: 32,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          GoBack(context);
                        },
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Setting',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'RobotoCondensed',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
                top: 150,
                child: Container(
                  padding: const EdgeInsets.only(left: 15, top: 20),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height - 150,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20, left: 8),
                    child: Column(
                      children: [
                        // profilevm.buildProfileOption(
                        //   context,
                        //   icon: Icons.email_rounded,
                        //   title: 'Change email',
                        //   onTap: () => openChangeMail(context),
                        // ),
                        // const SizedBox(
                        //   height: 12,
                        // ),
                        // profilevm.buildDivider(),
                        // const SizedBox(
                        //   height: 12,
                        // ),
                        profilevm.buildProfileOption(
                          context,
                          icon: Icons.lock,
                          title: 'Change password',
                          onTap: () => openChangePass(context),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        profilevm.buildDivider(),
                        const SizedBox(
                          height: 12,
                        ),
                        profilevm.buildProfileOption(
                          context,
                          icon: Icons.logout,
                          title: 'Log out',
                          onTap: () => logoutFromApp(context),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      );
    });
  }
}