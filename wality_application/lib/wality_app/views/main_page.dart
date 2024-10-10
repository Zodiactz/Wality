import 'package:flutter/material.dart';
import 'package:wality_application/wality_app/utils/nav_bar/custom_bottom_navbar.dart';
import 'package:wality_application/wality_app/utils/nav_bar/custom_floating_action_button.dart';
import 'package:wality_application/wality_app/views/home_page.dart';
import 'package:wality_application/wality_app/views/profile_page.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String _currentPage = 'HomePage.dart';
  PageController _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['initialPage'] == 'profile') {
        setState(() {
          _currentPage = 'ProfilePage.dart';
          _pageController.jumpToPage(1); // Navigate to ProfilePage
        });
      }
    });
  }

  void _navigateToPage(String page) {
    setState(() {
      _currentPage = page;
      _pageController.animateToPage(
        page == 'HomePage.dart' ? 0 : 1,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose(); // Dispose the PageController to avoid memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFD6F1F3), // Light color
                Color(0xFF0083AB), // Darker color
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.1, 1.0],
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent, // Keep background transparent to show the gradient
            body: PageView(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(), // Disables swipe gestures
              onPageChanged: (index) {
                setState(() {
                  _currentPage =
                      index == 0 ? 'HomePage.dart' : 'ProfilePage.dart';
                });
              },
              children: [
                HomePage(), // HomePage is still interactive
                ProfilePage(), // ProfilePage is still interactive
              ],
            ),
            bottomNavigationBar: CustomBottomNavBar(
              currentPage: _currentPage,
              onPageChanged: _navigateToPage,
            ),
            floatingActionButton: CustomFloatingActionButton(),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            resizeToAvoidBottomInset: false,
          ),
        ),
      ],
    );
  }
}
