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

final App app = App(AppConfiguration('wality-1-djgtexn'));
final userId = app.currentUser?.id;

class RewardPage extends StatefulWidget {
  @override
  _RewardPageState createState() => _RewardPageState();
}

class _RewardPageState extends State<RewardPage> {
  List<String> couponCheck = [];
  bool isLoading = true;
  Future<int?>? botAmount;

  @override
  void initState() {
    super.initState();
    fetchUserCoupons();
    botAmount = fetchbotEvent(userId!);
  }

  Future<int?> fetchbotEvent(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/userId/$userId'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data['eventBot'];
    } else {
      print('Failed to fetch waterId');
      return null;
    }
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
      Navigator.pop(context); // Close the pop-up
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
        preferredSize: const Size.fromHeight(kToolbarHeight + 55),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0083AB),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.chevron_left,
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
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(
                    top: 0.0), // Space between title and subtitle
                child: Text(
                  'Continue to save the bottles for unlocking new coupons!',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'RobotoCondensed',
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
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
            padding: const EdgeInsets.only(top: 0),
            child: SingleChildScrollView(
              child: FutureBuilder<List<dynamic>>(
                future: fetchRewards(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      flutter_async.ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No coupons available'));
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
              child: Container(
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
                          bD,
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
            if (isUsed)
              Positioned(
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
                  padding: EdgeInsets.all(16),
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
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  couponName,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 5),
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
                                style: TextStyle(
                                    fontSize: 48, fontWeight: FontWeight.bold),
                              ),
                              Text('Bottles', style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        ],
                      ),
                      Divider(thickness: 1, color: Colors.grey),
                      SizedBox(height: 5),

                      // Coupon description
                      Text(
                        fD,
                        textAlign: TextAlign.start,
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        impD,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),

                      // Warning message
                      Text(
                        'Show this coupon to the shop before pressing the button!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.red,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),

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
                            child: Text('Use Coupon'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Exit'),
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
