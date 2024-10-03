import 'package:flutter/material.dart';
import 'package:wality_application/wality_app/utils/nav_bar/custom_bottom_navbar.dart';
import 'package:wality_application/wality_app/utils/nav_bar/custom_floating_action_button.dart';

class CustomScaffold extends StatelessWidget {
  final Widget body;
  final String currentPage;

  const CustomScaffold({
    super.key,
    required this.body,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body, // The main content of the page
      backgroundColor: const Color(0xFF0083AB),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: const Padding(
        padding: EdgeInsets.only(top: 12),
        child: CustomFloatingActionButton(), // Custom FAB with scaling and popover
      ),
      bottomNavigationBar: CustomBottomNavBar(currentPage: currentPage), // Custom Bottom Navbar
    );
  }
}
