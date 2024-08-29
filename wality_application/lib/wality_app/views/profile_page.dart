import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wality_application/wality_app/utils/navigator_utils.dart';
import 'package:wality_application/wality_app/views/nav_bar/custom_bottom_navbar.dart';
import 'package:wality_application/wality_app/views/nav_bar/floating_action_button.dart';
import 'package:wality_application/wality_app/views_models/profile_vm.dart';
import 'package:realm/realm.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter/src/widgets/async.dart' as flutter_async;

final App app = App(AppConfiguration('wality-1-djgtexn'));
final userId = app.currentUser?.id;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<String?> usernameFuture = Future.value(null);

  @override
  void initState() {
    super.initState();
    usernameFuture =
        fetchUsername(userId!); // Assuming userId is not null here.
  }

  Future<String?> fetchUsername(String userId) async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8080/userId/$userId'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data['username'];
    } else {
      print('Failed to fetch username');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewModel>(builder: (context, profilevm, child) {
      return Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
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
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/cat.jpg',
                                width: 96,
                                height: 96,
                                fit: BoxFit.cover,
                              ),
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
                                        'Error loading username',
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
                                const Text(
                                  "UID: 999",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontFamily: 'RobotoCondensed',
                                  ),
                                ),
                                /*Container(
                                  width: 70,
                                  height: 20,
                                  margin: const EdgeInsets.only(top: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF342056),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Owner',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontFamily: 'RobotoCondensed',
                                      ),
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
                          /*profilevm.buildProfileOption(
                            context,
                            icon: Icons.bar_chart,
                            title: 'Summary Graph',
                            onTap: () => openSummaryGraphPage(context),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          profilevm.buildDivider(),
                          const SizedBox(
                            height: 12,
                          ),*/
                          profilevm.buildProfileOption(
                            context,
                            icon: Icons.person,
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
                            icon: Icons.payment,
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
                            icon: Icons.settings,
                            title: 'Setting',
                            onTap: () => openSettingPage(context),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          profilevm.buildDivider(),
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
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: const Padding(
            padding: EdgeInsets.only(top: 12),
            child: CustomFloatingActionButton()),
        bottomNavigationBar:
            const CustomBottomNavBar(currentPage: 'ProfilePage.dart'),
      );
    });
  }
}
