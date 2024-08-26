import 'package:flutter/material.dart';
import 'package:wality_application/wality_app/utils/navigator_utils.dart';

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
                        openHomePage(context);
                      },
                icon: Icon(
                  Icons.home,
                  color: currentPage == 'HomePage.dart'
                      ? const Color(0xFF0083AB)
                      : Colors.black,
                  size: 40,
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
                        openProfilePage(context);
                      },
                icon: Icon(
                  Icons.account_box,
                  color: currentPage == 'ProfilePage.dart'
                      ? const Color(0xFF0083AB)
                      : Colors.black,
                  size: 40,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
