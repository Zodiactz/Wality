import 'package:flutter/material.dart';
import 'package:wality_application/Authenpage/LogoPage.dart';
import 'package:wality_application/InsideApp/HomePage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wality',
      theme: ThemeData(
      ),
      //home: const HomePage(),
      home: const LogoPage(),

    );
  }
}

