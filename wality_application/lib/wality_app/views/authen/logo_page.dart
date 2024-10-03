import 'package:flutter/material.dart';
import 'package:wality_application/wality_app/utils/navigator_utils.dart';

class LogoPage extends StatelessWidget {
  const LogoPage({super.key});

  @override
  Widget build(BuildContext context) {
     openChoosewayPageFromLogoPage(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0083AB),
              Color.fromARGB(255, 33, 117, 143),
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
              // Logo
              Image.asset(
                'assets/images/Logo.png',
                width: 250,
                height: 250,
              ),
              const SizedBox(height: 1),
              // Title
              const Text(
                'Wality',
                style: TextStyle(
                  fontSize: 96,
                  fontFamily: 'RobotoCondensed',
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
