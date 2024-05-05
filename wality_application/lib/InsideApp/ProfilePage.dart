import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wality_application/InsideApp/HomePage.dart';
import 'package:wality_application/InsideApp/QRScannerPage.dart';
import 'package:wality_application/InsideApp/SettingPage.dart';
import 'package:wality_application/widget/MachineBox.dart';

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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 40),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0083AB),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: AppBar(
              title: const Text(
                'Profile',
                style: TextStyle(
                  fontSize: 24,
                  fontFamily: 'SairaCondensed',
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.settings),
                ),
              ],
              backgroundColor: Colors.transparent,
              elevation: 0,
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
            padding: const EdgeInsets.only(top: 160,left:16),
      child: ClipOval(
              child: Image.asset(
                'assets/images/cat.jpg',
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
    ),
    const Padding(padding: EdgeInsets.only(top: 160,left:216),
    child: Row(
      children: [
        Text('Username',style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold),),
      ],
    ),),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
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
              gradient: LinearGradient(
                colors: [
                  Color(0xFF26CBFF),
                  Color(0xFF6980FD),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Icon(Icons.water_drop, color: Colors.black, size: 36),
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
                onPressed: currentPage == 'ProfilePage.dart' ? null : () {
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
