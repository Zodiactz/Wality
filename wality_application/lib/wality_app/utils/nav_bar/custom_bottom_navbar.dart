import 'package:flutter/material.dart';
import 'package:wality_application/wality_app/utils/navigator_utils.dart';
import 'package:wality_application/wality_app/views/profile_page.dart';
import 'package:wality_application/wality_app/views/home_page.dart'; // Import your HomePage here

class CustomBottomNavBar extends StatefulWidget {
  final String currentPage;

  const CustomBottomNavBar({super.key, required this.currentPage});

  @override
  _CustomBottomNavBarState createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  double _homeIconScale = 1.0;
  double _profileIconScale = 1.0;

  void _navigateTo(BuildContext context, Widget page, {bool isProfilePage = false}) {
  Navigator.of(context).pushReplacement(PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const beginLeft = Offset(-1.0, 0.0); // From left to right
      const beginRight = Offset(1.0, 0.0); // From right to left
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var tween = Tween(
        begin: isProfilePage ? beginRight : beginLeft, 
        end: end,
      ).chain(CurveTween(curve: curve));

      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  ));
}


  void _onTapDownHome(TapDownDetails details) {
    setState(() {
      _homeIconScale = 0.9; // Scale down when pressed
    });
  }

  void _onTapUpHome(TapUpDetails details) {
    setState(() {
      _homeIconScale = 1.0; // Scale back to normal when released
    });
  }

  void _onTapCancelHome() {
    setState(() {
      _homeIconScale = 1.0; // Scale back to normal if the tap is canceled
    });
  }

  void _onTapDownProfile(TapDownDetails details) {
    setState(() {
      _profileIconScale = 0.9; // Scale down when pressed
    });
  }

  void _onTapUpProfile(TapUpDetails details) {
    setState(() {
      _profileIconScale = 1.0; // Scale back to normal when released
    });
  }

  void _onTapCancelProfile() {
    setState(() {
      _profileIconScale = 1.0; // Scale back to normal if the tap is canceled
    });
  }

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
              child: GestureDetector(
                onTapDown: _onTapDownHome,
                onTapUp: _onTapUpHome,
                onTapCancel: _onTapCancelHome,
                child: Transform.scale(
                  scale: _homeIconScale,
                  child: IconButton(
                    onPressed: widget.currentPage == 'HomePage.dart'
                        ? null
                        : () {
                            _navigateTo(context, const HomePage(), isProfilePage: false); // Home page slides from left
                          },
                    icon: Icon(
                      Icons.home,
                      color: widget.currentPage == 'HomePage.dart'
                          ? const Color(0xFF0083AB)
                          : Colors.black,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 40),
            child: Center(
              child: GestureDetector(
                onTapDown: _onTapDownProfile,
                onTapUp: _onTapUpProfile,
                onTapCancel: _onTapCancelProfile,
                child: Transform.scale(
                  scale: _profileIconScale,
                  child: IconButton(
                    onPressed: widget.currentPage == 'ProfilePage.dart'
                        ? null
                        : () {
                            _navigateTo(context, const ProfilePage(), isProfilePage: true); // Profile page slides from right
                          },
                    icon: Icon(
                      Icons.account_circle,
                      color: widget.currentPage == 'ProfilePage.dart'
                          ? const Color(0xFF0083AB)
                          : Colors.black,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
