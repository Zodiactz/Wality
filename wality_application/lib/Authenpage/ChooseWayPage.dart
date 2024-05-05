import 'package:flutter/material.dart';
import 'package:wality_application/Authenpage/SignInPage.dart';
import 'package:wality_application/Authenpage/SignUpPage.dart';

class ChooseWayPage extends StatelessWidget {
  const ChooseWayPage({super.key});

  @override
  Widget build(BuildContext context) {
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
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const SignInPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF342056),
                    fixedSize: const Size(250, 50)),
                child: const Text(
                  'Sign in',
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'SairaCondensed',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUpPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF342056),
                    fixedSize: const Size(250, 50)),
                child: const Text(
                  'Sign up',
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'SairaCondensed',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
