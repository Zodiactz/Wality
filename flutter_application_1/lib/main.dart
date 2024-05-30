import 'package:flutter/material.dart';
import 'InsideApp/DashboardPage.dart'; // Updated import statement

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clone Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ClonePage(), // Use ClonePage as the home widget
    );
  }
}
