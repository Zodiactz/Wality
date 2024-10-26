// profile_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:popover/popover.dart';
import 'package:provider/provider.dart';
import 'package:wality_application/wality_app/repo/realm_service.dart';
import 'package:wality_application/wality_app/repo/user_service.dart';
import 'package:wality_application/wality_app/utils/nav_bar/custom_bottom_navbar.dart';
import 'package:wality_application/wality_app/utils/nav_bar/custom_floating_action_button.dart';

import 'package:wality_application/wality_app/utils/navigator_utils.dart';
import 'package:wality_application/wality_app/views_models/profile_vm.dart';
import 'package:realm/realm.dart';
import 'package:flutter/src/widgets/async.dart' as flutter_async;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<String?> usernameFuture = Future.value(null);
  Future<String?> userImage = Future.value(null);
  Future<String?> uidFuture = Future.value(null);
  Future<String?> realNameFuture = Future.value(null);
  Future<String?> sIDFuture = Future.value(null);
  String imgURL = "";

  final UserService _userService = UserService();
  final RealmService _realmService = RealmService();

  @override
  void initState() {
    super.initState();
    final userId = _realmService.getCurrentUserId();
    if (userId != null) {
      usernameFuture = _userService.fetchUsername(userId); // Fetch username
      _userService.fetchUserImage(userId).then((value) {
        setState(() {
          imgURL = value!;
        });
      });
      sIDFuture = _userService.fetchSID(userId);
      realNameFuture = _userService.fetchRealName(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewModel>(builder: (context, profilevm, child) {
      return Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.transparent,
            ),
          ),
          Stack(
            children: [
              Positioned(
                child: Container(
                  height: kToolbarHeight + 200,
                  color: Colors.transparent,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF0083AB),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(width: 16),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 32, top: 60),
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              GestureDetector(
                                onTap: () =>
                                    OpenChangePictureAndUsernamePage(context),
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
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    onTap:
                                    () => OpenChangePictureAndUsernamePage(
                                        context);
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
                        ),
                        const SizedBox(width: 28),
                        Padding(
                          padding: const EdgeInsets.only(top: 56),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FutureBuilder<String?>(
                                future: usernameFuture,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      flutter_async.ConnectionState.waiting) {
                                    return const Text(
                                      'Loading...',
                                      style: TextStyle(
                                        fontSize: 24,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'RobotoCondensed-Thin',
                                      ),
                                    );
                                  } else if (snapshot.hasError) {
                                    return const Text(
                                      'Error',
                                      style: TextStyle(
                                        fontSize: 24,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'RobotoCondensed-Thin',
                                      ),
                                    );
                                  } else if (snapshot.hasData) {
                                    return Text(
                                      '${snapshot.data}',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'RobotoCondensed-Thin',
                                      ),
                                    );
                                  } else {
                                    return const Text(
                                      'Username not found',
                                      style: TextStyle(
                                        fontSize: 24,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'RobotoCondensed-Thin',
                                      ),
                                    );
                                  }
                                },
                              ),
                              FutureBuilder<String?>(
                                future: sIDFuture,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      flutter_async.ConnectionState.waiting) {
                                    return const Text(
                                      'Loading...',
                                      style: TextStyle(
                                        fontSize: 24,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'RobotoCondensed-Thin',
                                      ),
                                    );
                                  } else if (snapshot.hasError) {
                                    return const Text(
                                      'Error',
                                      style: TextStyle(
                                        fontSize: 24,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'RobotoCondensed-Thin',
                                      ),
                                    );
                                  } else if (snapshot.hasData) {
                                    return Text(
                                      'ID: ${snapshot.data}',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'RobotoCondensed-Thin',
                                      ),
                                    );
                                  } else {
                                    return const Text(
                                      'ID not found',
                                      style: TextStyle(
                                        fontSize: 24,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'RobotoCondensed-Thin',
                                      ),
                                    );
                                  }
                                },
                              ),
                              FutureBuilder<String?>(
                                future: realNameFuture,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      flutter_async.ConnectionState.waiting) {
                                    return const Text(
                                      'Loading...',
                                      style: TextStyle(
                                        fontSize: 24,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'RobotoCondensed-Thin',
                                      ),
                                    );
                                  } else if (snapshot.hasError) {
                                    return const Text(
                                      'Error',
                                      style: TextStyle(
                                        fontSize: 24,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'RobotoCondensed-Thin',
                                      ),
                                    );
                                  } else if (snapshot.hasData) {
                                    return Text(
                                      'Name: ${snapshot.data}',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'RobotoCondensed-Thin',
                                      ),
                                    );
                                  } else {
                                    return const Text(
                                      'Name not found',
                                      style: TextStyle(
                                        fontSize: 24,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'RobotoCondensed-Thin',
                                      ),
                                    );
                                  }
                                },
                              ), /*
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF342056),
                                  minimumSize: const Size(70, 20),
                                  padding: const EdgeInsets.only(top: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                onPressed: () {
                                  OpenChangePictureAndUsernamePage(context);
                                },
                                child: const Padding(
                                  padding: EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.edit,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'edit',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontFamily: 'RobotoCondensed',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),*/
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: 180, left: 16, right: 16, bottom: 36),
                child: Container(
                  height: 480,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20, left: 16),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 12,
                        ),
                        profilevm.buildProfileOption(
                          context,
                          icon: Icons.workspace_premium_sharp,
                          title: 'Reward',
                          onTap: () => openRewardPage(context),
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
                          icon: Icons.leaderboard_rounded,
                          title: 'Ranking',
                          onTap: () => openRankingPage(context),
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
                          icon: Icons.admin_panel_settings,
                          title: 'Admin',
                          onTap: () => openAdminPage(context),
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
                          icon: Icons.settings,
                          title: 'Setting',
                          onTap: () => openSettingPage(context),
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
          )
        ],
      );
    });
  }
}
