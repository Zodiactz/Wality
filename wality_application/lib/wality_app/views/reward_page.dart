// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, non_constant_identifier_names

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:wality_application/wality_app/repo/qrValid_service.dart';
import 'package:wality_application/wality_app/repo/realm_service.dart';
import 'package:wality_application/wality_app/utils/navigator_utils.dart';
import 'package:realm/realm.dart';
import 'dart:convert';
import 'package:wality_application/wality_app/utils/constant.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/src/widgets/async.dart' as flutter_async;
import 'package:wality_application/wality_app/repo/user_service.dart';

final App app = App(AppConfiguration('wality-1-djgtexn'));
final userId = app.currentUser?.id;

class RewardPage extends StatefulWidget {
  const RewardPage({super.key});

  @override
  _RewardPageState createState() => _RewardPageState();
}

class _RewardPageState extends State<RewardPage> {
  final UserService _userService = UserService();
  List<String> couponCheck = [];
  bool isLoading = true;
  Future<int?>? botAmount;
  int? waterAmount;
  final qrService = QRValidService();

  final UserService userService = UserService();
  final RealmService _realmService = RealmService();

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
      throw Exception("Failed to use coupon");
    }
  }

  @override
  void initState() {
    final userId = _realmService.getCurrentUserId();
    super.initState();
    fetchUserCoupons();
    botAmount = userService.fetchUserEventBot(userId!);
    _userService.fetchUserEventMl(userId).then((amount) {
      setState(() {
        waterAmount = amount;
      });
    });
  }

  // Keep all your existing methods for coupon functionality
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
      setState(() {
        isLoading = false;
      });
      throw Exception("Failed to load coupons: ${response.body}");
    }
  }

  Future<List<dynamic>> fetchRewards() async {
    final response = await http.get(Uri.parse('$baseUrl/getAllCoupons'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load rewards');
    }
  }

  void _showDialogSuccess(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                GoBack(context);
                // Resume scanning after dialog is dismissed
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0083AB), Color(0xFF005678)],
            ),
          ),
          child: SafeArea(
              child: Column(
            children: [
              _buildAppBar(context),

              // Rewards list with ranking page styling
              Expanded(
                child: FutureBuilder<List<dynamic>>(
                  future: fetchRewards(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        flutter_async.ConnectionState.waiting) {
                      return const Center(
                          child:
                              CircularProgressIndicator(color: Colors.white));
                    } else if (snapshot.hasError) {
                      return Center(
                          child: Text('Error: ${snapshot.error}',
                              style: const TextStyle(color: Colors.white)));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                          child: Text('No rewards available',
                              style: TextStyle(color: Colors.white)));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final reward = snapshot.data![index];
                        return _buildRewardItem(
                          context,
                          reward['coupon_id'],
                          reward['coupon_name'],
                          reward['b_desc'],
                          reward['bot_req'],
                          reward['img_couponLink'],
                          reward['f_desc'],
                          reward['imp_desc'],
                        );
                      },
                    );
                  },
                ),
              ),

              // Bottom info panel styled like ranking page
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'You saved bottles of this event',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: 'RobotoCondensed',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FutureBuilder<int?>(
                                  future: botAmount,
                                  builder: (context, snapshot) {
                                    return Text(
                                      '${snapshot.data ?? 0}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 60,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'RobotoCondensed',
                                        height:
                                            0.9, // Adjust this to reduce spacing
                                      ),
                                      textAlign: TextAlign.center,
                                    );
                                  },
                                ),
                                const SizedBox(
                                    height:
                                        4), // Add a small gap between the texts
                                Text(
                                  ' / ${waterAmount ?? 0} ML',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'RobotoCondensed',
                                    height: 0.9, // Adjust this as needed
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This event will end on 1/1/2025',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontFamily: 'RobotoCondensed',
                      ),
                    ),
                  ],
                ),
              )
            ],
          ))),
    );
  }

  Widget _buildRewardItem(
    BuildContext context,
    String cId,
    String couponName,
    String bD,
    int bReq,
    String imgCoupon,
    String fD,
    String impD,
  ) {
    bool isUsed = couponCheck.contains(cId);

    return GestureDetector(
      onTap: () => isUsed
          ? null
          : _showCouponPopup(
              context, couponName, bD, bReq, imgCoupon, fD, impD, cId),
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isUsed
                  ? Colors.white.withOpacity(0.05)
                  : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(imgCoupon),
                radius: 25,
              ),
              title: Text(
                couponName,
                style: TextStyle(
                  color: isUsed ? Colors.white38 : Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'RobotoCondensed',
                ),
              ),
              subtitle: Text(
                bD,
                style: TextStyle(
                  color: isUsed ? Colors.white24 : Colors.white70,
                  fontFamily: 'RobotoCondensed',
                ),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$bReq',
                    style: TextStyle(
                      color: isUsed ? Colors.white38 : Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'RobotoCondensed',
                    ),
                  ),
                  Text(
                    'Bottles',
                    style: TextStyle(
                      color: isUsed ? Colors.white24 : Colors.white70,
                      fontSize: 14,
                      fontFamily: 'RobotoCondensed',
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
    );
  }

  // Keep your existing _showCouponPopup method
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
                        'Coupon will generate QR code for scanning',
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
                            onPressed: () async {
                              if (hasEnoughBottles) {
                                await qrService.deleteALLQRofThisUser(userId!);
                                // Await the result of createQR to get the actual qr_id
                                final qr_id =
                                    await qrService.createQR(userId!, cId);

                                // Check if qr_id is not null before proceeding
                                if (qr_id != null) {
                                  GoBack(context);
                                  _showCouponPopupQR(
                                      context, qr_id, couponName);
                                  await fetchUserCoupons();
        
                                } else {
                                  // Handle the case where qr_id is null (optional)
                 
                                }
                              } else {
                                // Optionally handle the case where there aren't enough bottles
                     
                              }
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

  Future<void> _showCouponPopupQR(
      BuildContext context, String qr_id, String couponName) async {
    bool couponIsActive = false; // Track if the coupon is active
    bool qrCodeExpire = false; // Track if the QR code has expired

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                          const Text(
                            'QR Code for Scanning',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),

                          // Display appropriate icon based on coupon status
                          if (couponIsActive)
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 150.0,
                            )
                          else if (qrCodeExpire)
                            const Icon(
                              Icons.close_rounded,
                              color: Color.fromARGB(255, 187, 14, 14),
                              size: 200.0,
                            )
                          else
                            QrImageView(
                              data: qr_id,
                              version: QrVersions.auto,
                              size: 200.0,
                            ),

                          const SizedBox(height: 20),

                          // StreamBuilder to monitor coupon status
                          StreamBuilder<Map<String, dynamic>?>(
                            stream: _checkCouponStatusStream(qr_id),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  flutter_async.ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasError &&
                                  snapshot.error == 'expired') {
                                // Handle expired coupon
                                if (!qrCodeExpire) {
                                  qrCodeExpire = true; // Mark as expired
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    setState(() {}); // Update UI
                                  });
                                }

                                return const Text('QR Code has expired.');
                              } else if (!snapshot.hasData ||
                                  snapshot.data == null) {
                                // Handle used coupon
                                if (!couponIsActive && !qrCodeExpire) {
                                  couponIsActive = true; // Mark as used
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) async {
                                    setState(() {}); // Update UI
                                    _showDialogSuccess('Coupon Used!',
                                        'Coupon used successfully!');
                                    await fetchUserCoupons();
                                    GoBack(context); // Close dialog after use
                                  });
                                }

                                return const Text('Coupon used successfully.');
                              } else {
                                // Handle valid coupon

                                return Text(
                                  'Coupon is still valid: $couponName',
                                  style: const TextStyle(fontSize: 16),
                                );
                              }
                            },
                          ),

                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  GoBack(context);
                                  await qrService
                                      .deleteALLQRofThisUser(userId!);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                ),
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
      },
    );
  }

  Stream<Map<String, dynamic>?> _checkCouponStatusStream(String qrId) {
    final controller = StreamController<Map<String, dynamic>?>.broadcast();
    Timer? timer;
    bool isCouponUsed = false;

    Future<void> checkStatus() async {
      if (isCouponUsed) return;

      try {
        final couponData = await qrService.fetchRewardsByQRId(qrId);
        if (couponData == null) {
          isCouponUsed = true;
          controller.add(null);
          timer?.cancel();
          controller.close();
        } else {
          controller.add(couponData);
        }
      } catch (e) {
        if (!isCouponUsed) controller.addError('error_fetching_data');
      }
    }

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (isCouponUsed) {
        t.cancel();
        return;
      }

      if (t.tick >= 30) {
        controller.addError('expired');
        controller.close();
        t.cancel();
      } else {
        checkStatus();
      }
    });

    controller.onCancel = () => timer?.cancel();

    return controller.stream;
  }
}

Widget _buildAppBar(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Row(
      children: [
        IconButton(
          icon: const Icon(
            Icons.chevron_left,
            color: Colors.white,
            size: 32,
          ),
          onPressed: () => GoBack(context),
        ),
        const Expanded(
          child: Text(
            'Reward',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'RobotoCondensed',
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(width: 40),
      ],
    ),
  );
}
