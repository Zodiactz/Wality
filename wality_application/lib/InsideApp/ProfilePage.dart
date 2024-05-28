import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wality_application/InsideApp/SettingPage.dart';
import 'package:wality_application/InsideApp/WaterFilterMachinePage.dart';
import 'package:wality_application/widget/CustomBottomAppBar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  XFile? _selectedImage;

  @override
  Widget build(BuildContext context) {
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
          const ProfileHeader(),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: FloatingActionButton(
          onPressed: () async {
            final ImagePicker picker = ImagePicker();
            final XFile? image = await picker.pickImage(
              source: ImageSource.camera,
            );
            if (image != null) {
              setState(() {
                _selectedImage = image;
              });
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WaterFilterMachinePage(image: File(image.path)),
                ),
              );
            }
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.0),
          ),
          child: Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50.0),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF26CBFF),
                  Color(0xFF6980FD),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: const Icon(Icons.water_drop, color: Colors.black, size: 40),
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentPage: 'ProfilePage.dart'),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 16),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 32),
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
                        padding: const EdgeInsets.only(top: 60),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Username',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'SairaCondensed',
                              ),
                            ),
                            const Text(
                              'UID: 999999',
                              style: TextStyle(
                                fontSize: 24,
                                fontFamily: 'SairaCondensed',
                              ),
                            ),
                            Container(
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
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 180, left: 16, right: 16, bottom: 36),
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
              padding: const EdgeInsets.only(top: 40, left: 16),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingPage(),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF6D8093).withOpacity(0.2),
                          ),
                          padding: const EdgeInsets.all(5.0),
                          child: const Icon(
                            Icons.star,
                            size: 44,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Purchase Requisition History',
                          style: TextStyle(
                              fontSize: 20, fontFamily: 'SairaCondensed'),
                        ),
                        const Spacer(),
                        const Padding(
                          padding: EdgeInsets.only(right: 28),
                          child: Icon(Icons.chevron_right, size: 32),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(
                      color: Colors.grey,
                      thickness: 1,
                      indent: 2,
                      endIndent: 16,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingPage(),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF6D8093).withOpacity(0.2),
                          ),
                          padding: const EdgeInsets.all(5.0),
                          child: const Icon(
                            Icons.star,
                            size: 44,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Summary graph',
                          style: TextStyle(
                              fontSize: 20, fontFamily: 'SairaCondensed'),
                        ),
                        const Spacer(),
                        const Padding(
                          padding: EdgeInsets.only(right: 28),
                          child: Icon(Icons.chevron_right, size: 32),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(
                      color: Colors.grey,
                      thickness: 1,
                      indent: 2,
                      endIndent: 16,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingPage(),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF6D8093).withOpacity(0.2),
                          ),
                          padding: const EdgeInsets.all(5.0),
                          child: const Icon(
                            Icons.star,
                            size: 44,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Payment',
                          style: TextStyle(
                              fontSize: 20, fontFamily: 'SairaCondensed'),
                        ),
                        const Spacer(),
                        const Padding(
                          padding: EdgeInsets.only(right: 28),
                          child: Icon(Icons.chevron_right, size: 32),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(
                      color: Colors.grey,
                      thickness: 1,
                      indent: 2,
                      endIndent: 16,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingPage(),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF6D8093).withOpacity(0.2),
                          ),
                          padding: const EdgeInsets.all(5.0),
                          child: const Icon(
                            Icons.star,
                            size: 44,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Setting',
                          style: TextStyle(
                              fontSize: 20, fontFamily: 'SairaCondensed'),
                        ),
                        const Spacer(),
                        const Padding(
                          padding: EdgeInsets.only(right: 28),
                          child: Icon(Icons.chevron_right, size: 32),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(
                      color: Colors.grey,
                      thickness: 1,
                      indent: 2,
                      endIndent: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
