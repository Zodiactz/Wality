import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wality_application/wality_app/utils/navigator_utils.dart';
import 'package:wality_application/wality_app/utils/nav_bar/floating_action_button.dart';
import 'package:wality_application/wality_app/utils/nav_bar/custom_bottom_navbar.dart';

class RewardPage extends StatelessWidget {
  const RewardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 40),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0083AB),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: AppBar(
              backgroundColor: const Color(0xFF0083AB),
              elevation: 0,
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: const Icon(
                  Icons.chevron_left,
                  size: 32,
                ),
                onPressed: () {
                  GoBack(context);
                },
              ),
              title: const Padding(
                padding: EdgeInsets.only(right: 50),
                child: Center(
                  child: Text(
                    'Reward',
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'RobotoCondensed',
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFD6F1F3),
                  Color(0xFF0083AB),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.1, 1.0],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 320, top: 150),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => _showCouponPopup(context),

                    // Coupon widget starts here
                    child: Container(
                      width: 375,
                      height: 92,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            top: 0,
                            child: Container(
                              width: 375,
                              height: 92,
                              decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 14,
                            top: 9,
                            child: Container(
                              width: 75,
                              height: 74,
                              decoration: const ShapeDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(
                                      "https://firebasestorage.googleapis.com/v0/b/walityfirebase.appspot.com/o/2d0cc5bbfba97b1f-Untitled_Artwork.png?alt=media"),
                                  fit: BoxFit.fill,
                                ),
                                shape: OvalBorder(),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 99,
                            top: 9,
                            child: Container(
                              width: 205,
                              height: 70,
                              child: const Stack(
                                children: [
                                  Positioned(
                                    left: 0,
                                    top: 5,
                                    child: SizedBox(
                                      width: 205,
                                      height: 33,
                                      child: Text(
                                        'Lung Num Drink Shop',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20,
                                          fontFamily: 'Roboto Condensed',
                                          fontWeight: FontWeight.w700,
                                          height: 0,
                                          letterSpacing: -0.40,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 0,
                                    top: 40,
                                    child: SizedBox(
                                      width: 205,
                                      height: 33,
                                      child: Text(
                                        'Discount: 10 Baht',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontFamily: 'Roboto Condensed',
                                          fontWeight: FontWeight.w300,
                                          height: 0,
                                          letterSpacing: -0.36,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 294,
                            top: 16,
                            child: Container(
                              width: 67,
                              height: 74,
                              child: const Stack(
                                children: [
                                  Positioned(
                                    left: -17,
                                    top: 2,
                                    child: SizedBox(
                                      width: 100,
                                      height: 50,
                                      child: Text(
                                        '100',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 40,
                                          fontFamily: 'Roboto Condensed',
                                          fontWeight: FontWeight.w500,
                                          height: 0.7,
                                          letterSpacing: -1.28,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 0,
                                    top: 35,
                                    child: SizedBox(
                                      width: 67,
                                      height: 33,
                                      child: Text(
                                        'Bottles',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20,
                                          fontFamily: 'Roboto Condensed',
                                          fontWeight: FontWeight.w700,
                                          height: 0,
                                          letterSpacing: -0.40,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Coupon widget ends here
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _showCouponPopup(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          width: 375,
          height: 496,
          child: Stack(
            children: [
              // Add more content here for the popup
              // This is just a basic structure
              Positioned.fill(
                  child: Container(
                width: 375,
                height: 496,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      child: Container(
                        width: 375,
                        height: 496,
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 14,
                      top: 11,
                      child: Container(
                        width: 339,
                        height: 78,
                        child: Stack(
                          children: [
                            Positioned(
                              left: 0,
                              top: 0,
                              child: Container(
                                width: 75,
                                height: 74,
                                decoration: const ShapeDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(
                                        "https://via.placeholder.com/75x74"),
                                    fit: BoxFit.fill,
                                  ),
                                  shape: OvalBorder(),
                                ),
                              ),
                            ),
                            const Positioned(
                              left: 85,
                              top: 0,
                              child: SizedBox(
                                width: 205,
                                height: 33,
                                child: Text(
                                  'Lung Num Drink Shop',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontFamily: 'Roboto Condensed',
                                    fontWeight: FontWeight.w700,
                                    height: 0,
                                    letterSpacing: -0.40,
                                  ),
                                ),
                              ),
                            ),
                            const Positioned(
                              left: 277,
                              top: 45,
                              child: SizedBox(
                                width: 57,
                                height: 33,
                                child: Text(
                                  'Bottles',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontFamily: 'Roboto Condensed',
                                    fontWeight: FontWeight.w700,
                                    height: 0,
                                    letterSpacing: -0.40,
                                  ),
                                ),
                              ),
                            ),
                            const Positioned(
                              left: 272,
                              top: 6,
                              child: SizedBox(
                                width: 67,
                                height: 33,
                                child: Text(
                                  '10',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 64,
                                    fontFamily: 'Roboto Condensed',
                                    fontWeight: FontWeight.w500,
                                    height: 0,
                                    letterSpacing: -1.28,
                                  ),
                                ),
                              ),
                            ),
                            const Positioned(
                              left: 85,
                              top: 37,
                              child: SizedBox(
                                width: 205,
                                height: 33,
                                child: Text(
                                  'Discount: 10 Baht',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontFamily: 'Roboto Condensed',
                                    fontWeight: FontWeight.w300,
                                    height: 0,
                                    letterSpacing: -0.36,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 21,
                      top: 315,
                      child: Container(
                        width: 333,
                        height: 161,
                        child: Stack(
                          children: [
                            const Positioned(
                              left: 0,
                              top: 0,
                              child: SizedBox(
                                width: 333,
                                height: 64,
                                child: Text(
                                  'Show this coupon to the shop before press the button! ',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFFF60C0C),
                                    fontSize: 24,
                                    fontFamily: 'Roboto Condensed',
                                    fontWeight: FontWeight.w700,
                                    height: 0,
                                    letterSpacing: -0.48,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 26,
                              top: 64,
                              child: Container(
                                width: 281,
                                height: 97,
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: 0,
                                      top: 0,
                                      child: Container(
                                        width: 281,
                                        height: 44,
                                        child: const Stack(
                                          children: [
                                            Positioned(
                                              left: 65,
                                              top: 5,
                                              child: SizedBox(
                                                width: 151,
                                                height: 33,
                                                child: Text(
                                                  'Use this coupon',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 24,
                                                    fontFamily:
                                                        'Roboto Condensed',
                                                    fontWeight: FontWeight.w400,
                                                    height: 0,
                                                    letterSpacing: -0.48,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 0,
                                      top: 53,
                                      child: Container(
                                        width: 281,
                                        height: 44,
                                        child: const Stack(
                                          children: [
                                            Positioned(
                                              left: 65,
                                              top: 5,
                                              child: SizedBox(
                                                width: 151,
                                                height: 33,
                                                child: Text(
                                                  'EXIT',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 24,
                                                    fontFamily:
                                                        'Roboto Condensed',
                                                    fontWeight: FontWeight.w400,
                                                    height: 0,
                                                    letterSpacing: -0.48,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 22,
                      top: 106,
                      child: Container(
                        width: 333,
                        height: 98,
                        child: Stack(
                          children: [
                            Positioned(
                              left: 0,
                              top: 16,
                              child: SizedBox(
                                width: 333,
                                height: 82,
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text:
                                            'This coupon can be use to reduce price of drinks \nat Lung Num Drink shop by by 10 bath \n',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontFamily: 'Roboto Condensed',
                                          fontWeight: FontWeight.w300,
                                          height: 0,
                                          letterSpacing: -0.36,
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            '* Drinks that are include whip cream only*',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20,
                                          fontFamily: 'Roboto Condensed',
                                          fontWeight: FontWeight.w500,
                                          height: 0,
                                          letterSpacing: -0.40,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 0,
                              top: 1,
                              child: Container(
                                width: 333,
                                decoration: ShapeDecoration(
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      width: 1,
                                      strokeAlign: BorderSide.strokeAlignCenter,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      );
    },
  );
}
