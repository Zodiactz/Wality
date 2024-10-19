import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wality_application/wality_app/utils/navigator_utils.dart';
// import 'package:wality_application/wality_app/utils/nav_bar/floating_action_button.dart';
import 'package:wality_application/wality_app/utils/nav_bar/custom_bottom_navbar.dart';
import 'package:realm/realm.dart';
import 'dart:convert';
import 'package:wality_application/wality_app/utils/constant.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/src/widgets/async.dart' as flutter_async;
import 'package:wality_application/wality_app/repo/user_service.dart';

final App app = App(AppConfiguration('wality-1-djgtexn'));
final userId = app.currentUser?.id;

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  List<String> couponCheck = [];
  bool isLoading = true;
  Future<int?>? botAmount;
  final UserService userService = UserService();

  @override
  void initState() {
    super.initState();
    fetchUserCoupons();
    botAmount = userService.fetchUserEventBot(userId!);
  }

  Future<bool> userBotMoreThanEventBot(int couponBot) async {
    int userBot = await botAmount ?? 0;
    if (userBot < couponBot) {
      return false;
    } else {
      return true;
    }
  }

  Future<void> fetchUserCoupons() async {
    final response =
        await http.get(Uri.parse('http://localhost:8080/getCoupons/$userId'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        couponCheck = List<String>.from(data['couponCheck']);
        isLoading = false;
      });
    } else {
      // Handle error
      setState(() {
        isLoading = false;
      });
      print("Failed to load coupons: ${response.body}");
    }
  }

  Future<List<dynamic>> fetchRewards() async {
    final response = await http.get(Uri.parse(
        '$baseUrl/getAllCoupons')); // Replace with your actual endpoint

    if (response.statusCode == 200) {
      return json.decode(response.body); // Parse the response body as JSON
    } else {
      throw Exception('Failed to load rewards');
    }
  }

  void useCoupon(String couponId, String userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/updateUserCouponCheck/$userId'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"couponCheck": couponId}),
    );

    if (response.statusCode == 200) {
      // Close the pop-up
      await fetchUserCoupons(); // Fetch updated coupons
      GoBack(context);
    } else {
      // Handle the error
      print('Failed to use coupon');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 50),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0083AB),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0083AB).withOpacity(1),
                spreadRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 32),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.chevron_left,
                        color: Colors.black,
                        size: 32,
                      ),
                      onPressed: () {
                        GoBack(context);
                      },
                    ),
                    const Expanded(
                      child: Center(
                        child: Padding(
                          padding:
                              EdgeInsets.only(right: 46.0), // Right padding
                          child: Text(
                            'Admin',
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
                  ],
                ),
              ),
            ],
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
            padding: const EdgeInsets.only(top: 8),
            child: SingleChildScrollView(
              child: FutureBuilder<List<dynamic>>(
                future: fetchRewards(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      flutter_async.ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No coupons available'));
                  }

                  // Create coupon widgets from the fetched rewards data
                  List<Widget> couponWidgets = snapshot.data!.map((reward) {
                    return buildCouponWidget(
                      context,
                      reward['coupon_id'],
                      reward['coupon_name'],
                      reward['b_desc'],
                      reward['bot_req'],
                      reward['img_couponLink'],
                      reward['f_desc'],
                      reward['imp_desc'],
                    );
                  }).toList();

                  return Center(
                    child: Column(
                      children: couponWidgets,
                    ),
                  );
                },
              ),
            ),
          ),
          // White floating bar at the bottom
          Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: MediaQuery.of(context)
                    .size
                    .width, // Full width of the screen
                height: MediaQuery.of(context).size.height *
                    0.17, // 8% of screen height for the floating bar
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, -1), // Position of the shadow
                    ),
                  ],
                ),

                child: Column(
                  children: [
                    const Text(
                      'You saved bottles of this event', // Add any text or action buttons
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'RobotoCondensed',
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 0.1),
                      child: FutureBuilder<int?>(
                        future: botAmount,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              flutter_async.ConnectionState.waiting) {
                            return const Text(
                              'Loading',
                              style: TextStyle(
                                fontSize: 50,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'RobotoCondensed-Thin',
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return const Text(
                              'Error',
                              style: TextStyle(
                                fontSize: 50,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'RobotoCondensed-Thin',
                              ),
                            );
                          } else if (snapshot.hasData) {
                            return Text(
                              '${snapshot.data}',
                              style: const TextStyle(
                                fontSize: 50,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'RobotoCondensed-Thin',
                              ),
                            );
                          } else {
                            return const Text(
                              'Bot not Found',
                              style: TextStyle(
                                fontSize: 50,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'RobotoCondensed-Thin',
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    const Text(
                      'This event will be end at 1/1/2025', // Add any text or action buttons
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'RobotoCondensed',
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget buildCouponWidget(BuildContext context, String cId, String couponName,
      String bD, int bReq, String imgCoupon, String fD, String impD) {
    bool isUsed = couponCheck.contains(cId);

    return GestureDetector(
      onTap: () => isUsed
          ? null
          : _showCouponPopup(
              context, couponName, bD, bReq, imgCoupon, fD, impD, cId),
      child: Container(
        padding: const EdgeInsets.only(top: 10),
        width: 375,
        height: 102,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              child: Container(
                width: 375,
                height: 92,
                decoration: ShapeDecoration(
                  color: isUsed ? Colors.grey : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 14,
              top: 9,
              child: CircleAvatar(
                backgroundImage: NetworkImage(imgCoupon),
                radius: 37,
              ),
            ),
            Positioned(
              left: 99,
              top: 9,
              child: SizedBox(
                width: 205,
                height: 70,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      top: 5,
                      child: SizedBox(
                        width: 205,
                        height: 33,
                        child: Text(
                          couponName,
                          style: const TextStyle(
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
                          bD,
                          style: const TextStyle(
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
              child: SizedBox(
                width: 67,
                height: 74,
                child: Stack(
                  children: [
                    Positioned(
                      left: -17,
                      top: 2,
                      child: SizedBox(
                        width: 100,
                        height: 50,
                        child: Text(
                          '$bReq',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
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
                    const Positioned(
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
            if (isUsed)
              const Positioned(
                left: 150,
                top: 30,
                child: Text(
                  'Used',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCouponPopup(
      BuildContext context,
      String couponName,
      String bD,
      int bReq,
      String imgCoupon,
      String fD,
      String impD,
      String cId) async {
    bool hasEnoughBottles = await userBotMoreThanEventBot(bReq);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.8,
                    maxWidth: MediaQuery.of(context).size.width * 0.9,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Image and coupon details
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(imgCoupon),
                            radius: 37,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  couponName,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  bD,
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                '$bReq',
                                style: const TextStyle(
                                    fontSize: 48, fontWeight: FontWeight.bold),
                              ),
                              const Text('Bottles',
                                  style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        ],
                      ),
                      const Divider(thickness: 1, color: Colors.grey),
                      const SizedBox(height: 5),

                      // Coupon description
                      Text(
                        fD,
                        textAlign: TextAlign.start,
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        impD,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),

                      // Warning message
                      const Text(
                        'Show this coupon to the shop before pressing the button!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.red,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),

                      // Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              if (hasEnoughBottles) {
                                useCoupon(cId, userId!);
                                print(
                                    "///////////cid=$cId//////$hasEnoughBottles");
                              } else {
                                null;
                              }
                              // Use coupon action
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  hasEnoughBottles ? Colors.blue : Colors.grey,
                            ),
                            child: const Text('Use Coupon'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              GoBack(context);
                            },
                            child: const Text('Exit'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
