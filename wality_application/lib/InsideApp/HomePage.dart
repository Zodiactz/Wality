import 'package:flutter/material.dart';
import 'package:wality_application/InsideApp/SettingPage.dart';
import 'package:wality_application/widget/BottomNavBar.dart';
import 'package:wality_application/widget/MachineBox.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 40),
        child: Container(
          decoration: BoxDecoration(
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
                'Homey',
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
          Positioned(
            top: 160,
            left: 36,
            child: MachineBox(),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 22, 148, 187),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: BottomNavBar(),
      ),
    );
  }
}
