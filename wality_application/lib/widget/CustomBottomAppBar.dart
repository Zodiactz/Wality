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
            padding: const EdgeInsets.only(left: 40),
            child: Center(
              child: IconButton(
                onPressed: currentPage == 'HomePage.dart'
                    ? null
                    : () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomePage(),
                          ),
                        );
                      },
                icon: Icon(
                  Icons.home,
                  color: currentPage == 'HomePage.dart' ? Color(0xFF0083AB) : Colors.black,
                  size: 36,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 40),
            child: Center(
              child: IconButton(
                onPressed: currentPage == 'ProfilePage.dart'
                    ? null
                    : () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfilePage(),
                          ),
                        );
                      },
                icon: Icon(
                  Icons.account_box,
                  color: currentPage == 'ProfilePage.dart' ? Color(0xFF0083AB) : Colors.black,
                  size: 36,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
