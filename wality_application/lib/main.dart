import 'package:flutter/material.dart';
import 'package:wality_application/Authenpage/LogoPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.transparent,
      ),
      home: const LogoPage(),
    );
  }
}

