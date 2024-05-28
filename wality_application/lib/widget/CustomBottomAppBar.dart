import 'package:flutter/material.dart';
import 'package:wality_application/InsideApp/HomePage.dart';
import 'package:wality_application/InsideApp/ProfilePage.dart';

class CustomBottomNavBar extends StatelessWidget {
  final String currentPage;

  const CustomBottomNavBar({super.key, required this.currentPage});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 16,
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 36),
            child: currentPage == 'HomePage.dart'
                ? const Icon(Icons.home, color: Color(0xFF0083AB), size: 36)
                : IconButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomePage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.home, color: Colors.black, size: 36),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 36),
            child: currentPage == 'ProfilePage.dart'
                ? const Icon(Icons.account_box, color: Color(0xFF0083AB), size: 36)
                : IconButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfilePage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.account_box),
                    iconSize: 36,
                  ),
          ),
        ],
      ),
      
    );
    
  }
}
