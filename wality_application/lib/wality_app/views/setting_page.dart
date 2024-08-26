import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wality_application/wality_app/utils/navigator_utils.dart';
import 'package:wality_application/wality_app/views_models/profile_vm.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

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
                          Navigator.pop(context);
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
                    padding: const EdgeInsets.only(top: 20, left: 16),
                    child: Column(
                      children: [
                        profilevm.buildProfileOption(
                          context,
                          icon: Icons.person,
                          title: 'Change Username and Password',
                          onTap: () => openChangeInfoPage(context),
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
                          onTap: () => LogOutToOutsite(context),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        profilevm.buildDivider(),
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
