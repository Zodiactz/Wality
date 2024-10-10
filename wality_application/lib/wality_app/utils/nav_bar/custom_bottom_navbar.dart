import 'package:flutter/material.dart';
import 'package:wality_application/wality_app/utils/navigator_utils.dart';
import 'package:wality_application/wality_app/views/profile_page.dart';
import 'package:wality_application/wality_app/views/home_page.dart';

class CustomBottomNavBar extends StatefulWidget {
  final String currentPage;
  final Function(String) onPageChanged;

  const CustomBottomNavBar({
    super.key,
    required this.currentPage,
    required this.onPageChanged,
  });

  @override
  _CustomBottomNavBarState createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  double _homeIconScale = 1.0;
  double _profileIconScale = 1.0;

 
  void _onTapDownHome(TapDownDetails details) {
    setState(() {
      _homeIconScale = 0.9;
    });
  }

  void _onTapUpHome(TapUpDetails details) {
    setState(() {
      _homeIconScale = 1.0;
    });
  }

  void _onTapCancelHome() {
    setState(() {
      _homeIconScale = 1.0;
    });
  }

  void _onTapDownProfile(TapDownDetails details) {
    setState(() {
      _profileIconScale = 0.9;
    });
  }

  void _onTapUpProfile(TapUpDetails details) {
    setState(() {
      _profileIconScale = 1.0;
    });
  }

  void _onTapCancelProfile() {
    setState(() {
      _profileIconScale = 1.0;
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
            child: GestureDetector(
              onTapDown: _onTapDownHome,
              onTapUp: _onTapUpHome,
              onTapCancel: _onTapCancelHome,
              child: Transform.scale(
                scale: _homeIconScale,
                child: IconButton(
                  icon: Icon(
                    Icons.home,
                    color: widget.currentPage == 'HomePage.dart'
                        ? const Color(0xFF0083AB)
                        : Colors.black,
                    size: 40,
                  ),
                  onPressed: () => widget.onPageChanged('HomePage.dart'),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 40),
            child: GestureDetector(
              onTapDown: _onTapDownProfile,
              onTapUp: _onTapUpProfile,
              onTapCancel: _onTapCancelProfile,
              child: Transform.scale(
                scale: _profileIconScale,
                child: IconButton(
                  icon: Icon(
                    Icons.account_circle,
                    color: widget.currentPage == 'ProfilePage.dart'
                        ? const Color(0xFF0083AB)
                        : Colors.black,
                    size: 40,
                  ),
                  onPressed: () => widget.onPageChanged('ProfilePage.dart'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}