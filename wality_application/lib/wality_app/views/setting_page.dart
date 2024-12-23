import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';
import 'package:wality_application/wality_app/repo/auth_service.dart';
import 'package:wality_application/wality_app/utils/navigator_utils.dart';
import 'package:wality_application/wality_app/views_models/setting_vm.dart';

class SettingPage extends StatelessWidget {
  SettingPage({super.key});
  final App app = App(AppConfiguration('wality-1-djgtexn'));
  final authService = AuthService();

  

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        body: Consumer<SettingViewModel>(builder: (context, settingvm, child) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0083AB), Color(0xFF003545)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildAppBar(context),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(left: 15, top: 4),
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
                          settingvm.buildSettingOption(
                            context,
                            icon: Icons.lock,
                            title: 'Change password',
                            onTap: () => openChangePass(context),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          settingvm.buildDivider(),
                          const SizedBox(
                            height: 12,
                          ),
                          settingvm.buildSettingOption(
                            context,
                            icon: Icons.logout,
                            title: 'Log out',
                            onTap: () => LogOutToOutsite(context),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }));
  }
}

Widget _buildAppBar(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Row(
      children: [
        IconButton(
          icon: const Icon(
            Icons.chevron_left,
            color: Colors.white,
            size: 32,
          ),
          onPressed: () => GoBack(context),
        ),
        const Expanded(
          child: Text(
            'Setting',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'RobotoCondensed',
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(width: 40),
      ],
    ),
  );
}

/*

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
*/