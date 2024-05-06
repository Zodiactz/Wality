import 'package:flutter/material.dart';
import 'package:wality_application/Authenpage/ChooseWayPage.dart';
import 'package:wality_application/InsideApp/HomePage.dart';


class SettingPage extends StatelessWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD6F1F3),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Padding(
          padding: const EdgeInsets.only(right:50),
          child: Container(
            child: Text(
              'Settings',
              style: TextStyle(
                fontSize: 24,
                fontFamily: 'SairaCondensed',
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      body: Container(
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 50, left: 24),
              child: Row(
                children: [
                  const Icon(
                    Icons.logout,
                    size: 40,
                    color: Colors.black,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ChooseWayPage()),
                        );
                      },
                      child: Text(
                        'Log Out',
                        style: TextStyle(
                          fontSize: 24,
                          fontFamily: 'SairaCondensed',
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
