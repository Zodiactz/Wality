import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wality_application/InsideApp/HomePage.dart';
import 'package:wality_application/InsideApp/QRScannerPage.dart';
import 'package:wality_application/InsideApp/SettingPage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String currentPage = 'ProfilePage.dart';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false, // Set automaticallyImplyLeading to false here
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingPage(),
                  ),
                );
              },
              icon: const Icon(Icons.settings),
            ),
          ),
        ],
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
          const ProfileHeader(), // Include the profile header widget here
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF26CBFF),
              Color(0xFF6980FD),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(50.0),
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => QRScannerPage()),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.0),
          ),
          child: Container(
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
            child: const Icon(Icons.water_drop, color: Colors.black, size: 36),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 12,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 36),
              child: IconButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HomePage(),
                    ),
                  );
                },
                icon: Icon(Icons.home,
                    color: currentPage == 'HomePage.dart'
                        ? const Color(0xFF0083AB)
                        : Colors.black),
                iconSize: 36,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 36),
              child: IconButton(
                onPressed: currentPage == 'ProfilePage.dart'
                    ? null
                    : () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomePage(),
                          ),
                        );
                      },
                icon: Icon(Icons.account_box,
                    color: currentPage == 'ProfilePage.dart'
                        ? const Color(0xFF0083AB)
                        : Colors.black),
                iconSize: 36,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

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
                      const Padding(
                        padding: EdgeInsets.only(top: 70),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Username',
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'SairaCondensed'),
                            ),
                            Text(
                              'UID: 999999',
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'SairaCondensed'),
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
        Positioned(
          top: kToolbarHeight + 120, // Adjust the top position as needed
          left: 16,
          right: 16,
          child: Container(
            height: 535,
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
                        const Spacer(), // Add Spacer widget here to move the Divider to the right end
                        const Padding(
                          padding: EdgeInsets.only(right: 28),
                          child: Icon(Icons.chevron_right, size: 32),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: 8), // Adjust vertical padding as needed
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
                        const Spacer(), // Add Spacer widget here to move the Divider to the right end
                        const Padding(
                          padding: EdgeInsets.only(right: 28),
                          child: Icon(Icons.chevron_right, size: 32),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: 8), // Adjust vertical padding as needed
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
