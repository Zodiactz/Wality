// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, non_constant_identifier_names, implementation_imports

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:realm/realm.dart';
import 'package:wality_application/wality_app/repo/qrValid_service.dart';
import 'package:wality_application/wality_app/repo/realm_service.dart';
import 'package:wality_application/wality_app/repo/reward_service.dart';
import 'package:wality_application/wality_app/utils/navigator_utils.dart';
import 'dart:convert';
import 'package:wality_application/wality_app/utils/constant.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/src/widgets/async.dart' as flutter_async;
import 'package:realm_dart/src/session.dart' as realm_session;
import 'package:wality_application/wality_app/repo/user_service.dart';
import 'package:intl/intl.dart';
import 'package:wality_application/wality_app/utils/constant.dart';

final App app = App(AppConfiguration('wality-1-djgtexn'));
final userId = app.currentUser?.id;

class RewardPage extends StatefulWidget {
  const RewardPage({super.key});

  @override
  _RewardPageState createState() => _RewardPageState();
}

class _RewardPageState extends State<RewardPage> {
  final UserService _userService = UserService();
  final RewardService _rewardService = RewardService();
  List<String> couponCheck = [];
  bool isLoading = true;
  Future<int?>? botAmount;
  int? waterAmount;
  final qrService = QRValidService();

  final UserService userService = UserService();
  final RealmService _realmService = RealmService();

  @override
  void initState() {
    final userId = _realmService.getCurrentUserId();
    super.initState();
    fetchUserCoupons();
    botAmount = userService.fetchUserEventBot(userId!);
    _userService.fetchWaterAmount(userId).then((amount) {
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

  (String, Color) calculateDaysUntilReCoupon(int repDay, int countStart) {
    int daysLeft = repDay - countStart;

    // Return red color if 3 or fewer days left
    if (daysLeft <= 3) {
      return ('$daysLeft days left until the coupon replenished', Colors.red);
    }

    return ('$daysLeft days left until the coupon replenished', Colors.green);
  }

  Future<void> fetchUserCoupons() async {
    final response =
        await http.get(Uri.parse('$baseUrl/getCoupons/$userId'));

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
                  future: _rewardService.fetchRewards(),
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

                    // Sort rewards based on `bot_req` in ascending order
                    final sortedRewards = snapshot.data!
                      ..sort((a, b) => a['bot_req'].compareTo(b['bot_req']));

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: sortedRewards.length,
                      itemBuilder: (context, index) {
                        final reward = sortedRewards[index];
                        return _buildRewardItem(
                          context,
                          reward['coupon_id'],
                          reward['coupon_name'],
                          reward['b_desc'],
                          reward['bot_req'],
                          reward['img_couponLink'],
                          reward['f_desc'],
                          reward['imp_desc'],
                          reward['exp_date'],
                        );
                      },
                    );
                  },
                ),
              ),

              // Bottom info panel styled like ranking page
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0083AB), Color(0xFF005678)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                padding: const EdgeInsets.all(5),
                child: Column(
                  children: [
                    const Text(
                      'Your W Coin',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: 'RobotoCondensedCondensed',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
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
                                        fontFamily: 'RobotoCondensedCondensed',
                                        height:
                                            0.9, // Adjust this to reduce spacing
                                      ),
                                      textAlign: TextAlign.center,
                                    );
                                  },
                                ),
                                const SizedBox(width: 5),
                                Image.asset(
                                  'assets/images/wCoin.png',
                                  width: 55,
                                  height: 55,
                                  fit: BoxFit.cover,
                                ),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'W Coin can be collected from filling up the water!',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontFamily: 'RobotoCondensedCondensed',
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  //Coupon item
  Widget _buildRewardItem(
    BuildContext context,
    String cId,
    String couponName,
    String bD,
    int bReq,
    String imgCoupon,
    String fD,
    String impD,
    String expD,
  ) {
    bool isUsed = couponCheck.contains(cId);

    return GestureDetector(
      onTap: () => _showCouponPopup(context, couponName, bD, bReq, imgCoupon,
          fD, impD, cId, expD, isUsed),
      child: Stack(
        alignment: Alignment.center, // Center align elements in the stack
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
                  fontFamily: 'RobotoCondensedCondensed',
                ),
              ),
              subtitle: Text(
                bD,
                style: TextStyle(
                  color: isUsed ? Colors.white24 : Colors.white70,
                  fontFamily: 'RobotoCondensedCondensed',
                ),
              ),
              trailing: SizedBox(
                height: 60, // Constrain height to prevent overflow
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '$bReq',
                      style: TextStyle(
                        color: isUsed ? Colors.white38 : Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'RobotoCondensedCondensed',
                      ),
                    ),
                    Flexible(
                      child: Transform.translate(
                        offset: const Offset(0, -6), // Move "Bottles" up a bit
                        child: Text(
                          'Coins',
                          style: TextStyle(
                              color: isUsed ? Colors.white24 : Colors.white70,
                              fontSize: 12, // Adjust font size if needed
                              fontFamily: 'RobotoCondensed'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isUsed)
            const Center(
              // Use Center widget to align text in the center
              child: Text(
                'Used',
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'RobotoCondensed'),
              ),
            ),
        ],
      ),
    );
  }

  //Coupon popup
  Future<void> _showCouponPopup(
      BuildContext context,
      String couponName,
      String bD,
      int bReq,
      String imgCoupon,
      String fD,
      String impD,
      String cId,
      String expD,
      bool isUsed) async {
    DateTime dateTime = DateTime.parse(expD);
    String formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);
    bool hasEnoughBottles = await userBotMoreThanEventBot(bReq);
    print("This is is Used: $isUsed");

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                padding: const EdgeInsets.all(16),
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Fixed Header
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
                                  fontFamily: 'RobotoCondensed',
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                bD,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontFamily: 'RobotoCondensed',
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              '$bReq',
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'RobotoCondensed',
                              ),
                            ),
                            const Text(
                              'Coins',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'RobotoCondensed',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(thickness: 1, color: Colors.grey),

                    // Scrollable Content
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 5),
                            Text(
                              fD,
                              textAlign: TextAlign.start,
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: 'RobotoCondensed',
                              ),
                            ),
                            Text(
                              impD,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'RobotoCondensed',
                              ),
                            ),
                            const SizedBox(height: 5),
                            FutureBuilder<Map<String, dynamic>>(
                              future: _rewardService.fetchRewardById(cId),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  final (reCouponText, textColor) =
                                      calculateDaysUntilReCoupon(
                                    snapshot.data!['rep_day'] as int,
                                    snapshot.data!['countStart'] as int,
                                  );
                                  return Text(
                                    reCouponText,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'RobotoCondensedCondensed',
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                            const SizedBox(height: 5),
                            Text.rich(
                              TextSpan(
                                children: [
                                  const TextSpan(
                                    text: 'Expired Date: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      fontFamily: 'RobotoCondensed',
                                    ),
                                  ),
                                  TextSpan(
                                    text: formattedDate,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'RobotoCondensed',
                                    ),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Fixed Footer
                    Column(
                      children: [
                        const Divider(thickness: 1, color: Colors.grey),
                        const SizedBox(height: 10),
                        const Text(
                          'Coupon will generate QR code for scanning',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'RobotoCondensed',
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                if (hasEnoughBottles && !isUsed) {
                                  await qrService
                                      .deleteALLQRofThisUser(userId!);
                                  final qr_id =
                                      await qrService.createQR(userId!, cId);
                                  if (qr_id != null) {
                                    GoBack(context);
                                    _showCouponPopupQR(
                                        context, qr_id, couponName);
                                    await fetchUserCoupons();
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: hasEnoughBottles && !isUsed
                                    ? Colors.blue
                                    : Colors.grey,
                              ),
                              child: const Text(
                                'Use Coupon',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'RobotoCondensed',
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                GoBack(context);
                              },
                              child: const Text(
                                'Exit',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'RobotoCondensed',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
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
        return WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: StatefulBuilder(
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
                                  }

                                  // Prioritize the expired coupon case immediately
                                  if (snapshot.hasError) {
                                    final error = snapshot.error;
                                    if (error == 'expired') {
                                      if (!qrCodeExpire) {
                                        qrCodeExpire = true;
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                          setState(() {});
                                        });
                                      }
                                      return const Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'QR Code has expired.',
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      );
                                    }
                                  }

                                  // Handle used coupon case
                                  if (!snapshot.hasData ||
                                      snapshot.data == null) {
                                    if (!couponIsActive && !qrCodeExpire) {
                                      couponIsActive = true;
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) async {
                                        setState(() {});
                                        _showDialogSuccess('Coupon Used!',
                                            'Coupon used successfully!');
                                        await fetchUserCoupons();
                                        GoBack(context);
                                      });
                                    }

                                    return const Text(
                                      'Coupon used successfully.',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  }

                                  // Check if the coupon is expired and display "Invalid" if so
                                  return Text(
                                    qrCodeExpire
                                        ? 'Qr code has expired!!!'
                                        : 'Coupon is still valid: $couponName',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: qrCodeExpire
                                          ? Colors.red
                                          : Colors.blue,
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 20),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
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
                                      child: const Text('Exit',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ))),
                                ],
                              ),
                            ],
                          )),
                    );
                  },
                ),
              );
            },
          ),
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

//App bar
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
          onPressed: () => openProfilePage(context),
        ),
        const Expanded(
          child: Text(
            'Reward',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'RobotoCondensedCondensed',
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(width: 40),
      ],
    ),
  );
}
