import 'package:flutter/material.dart';
import 'package:wality_application/Authenpage/ChooseWayPage.dart';
class LogoPage extends StatelessWidget {
  const LogoPage({super.key});

  @override
  Widget build(BuildContext context) {
     Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ChooseWayPage()),
      );
    });
    return Scaffold(
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/cat.jpg',
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 4),
              const Text(
                'Wality',
                style: TextStyle(
                  fontSize: 96,
                  fontFamily: 'SairaCondensed',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
