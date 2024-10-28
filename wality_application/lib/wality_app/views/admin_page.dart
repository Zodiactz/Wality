import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:wality_application/wality_app/repo/qrValid_service.dart';
import 'package:wality_application/wality_app/utils/constant.dart';
import 'package:wality_application/wality_app/utils/navigator_utils.dart';
import 'package:wality_application/wality_app/repo/user_service.dart';
import 'package:wality_application/wality_app/repo/realm_service.dart';
import 'package:wality_application/wality_app/repo/water_service.dart';
import 'package:http/http.dart' as http;
import 'package:wality_application/wality_app/views/reward_page.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final UserService _userService = UserService();
  final RealmService _realmService = RealmService();
  final WaterService _waterService = WaterService();
  List<dynamic> _users = [];
  List<dynamic> _filteredUsers = [];
  bool _isLoading = true;
  String? currentUserId;
  TextEditingController searchController = TextEditingController();
  bool _isScanning = false;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  final qrService = QRValidService();
  String? usernameFuture;


  @override
  void initState() {
    super.initState();
    currentUserId = _realmService.getCurrentUserId();
    _loadUsers();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    } else if (Platform.isIOS) {
      controller?.resumeCamera();
    }
  }

  Future<void> _loadUsers() async {
    if (currentUserId == null) {
      LogOutToOutsite(context);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final users = await _userService.fetchUsers();
      setState(() {
        _users = users;
        _filteredUsers = List.from(users);
        _sortUsers(_filteredUsers);
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading users: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _sortUsers(List<dynamic> users) {
    users.sort((a, b) {
      String usernameA = (a['username'] ?? '').toString().toLowerCase();
      String usernameB = (b['username'] ?? '').toString().toLowerCase();
      return usernameA.compareTo(usernameB);
    });
  }

  void _filterUsers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = List.from(_users);
      } else {
        _filteredUsers = _users.where((user) {
          final username = (user['username'] ?? '').toString().toLowerCase();
          return username.contains(query.toLowerCase());
        }).toList();
      }
      _sortUsers(_filteredUsers);
    });
  }

  ImageProvider _getProfileImage(String? profileImgLink) {
    if (profileImgLink != null && profileImgLink.isNotEmpty) {
      return NetworkImage(profileImgLink);
    } else {
      return const AssetImage('assets/images/cat.jpg');
    }
  }

  void _showDialogWithAutoDismiss(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: const <Widget>[
            // No action buttons to ensure the dialog cannot be dismissed
          ],
        );
      },
    );
  }

  void _showDialog(String title, String message) {
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
                controller?.resumeCamera();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDialogAndGoToAdmin(String title, String message) {
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
                openAdminPage(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showDialogContinue(String title, String message, int sentCurrentWaterGo,
      int sentCurrentBottleGo, int sentWaterAmountGo) {
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
              },
            ),
          ],
        );
      },
    );
  }

  void _startQRScanner() {
    setState(() {
      _isScanning = true;
    });
  }

  void useCoupon(String couponId, String userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/updateUserCouponCheck/$userId'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"couponCheck": couponId}),
    );

    if (response.statusCode == 200) {
      // Close the pop-up
      GoBack(context);
    } else {
      // Handle the error
      print('Failed to use coupon');
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      // Pause scanning while processing
      controller.pauseCamera();

      // Show dialog indicating scanning
      _showDialogWithAutoDismiss(
          'Scanning', 'Please wait while we process the QR code...');

      // Ensure the dialog is shown before proceeding
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // Introduce a delay of 2 seconds
        await Future.delayed(const Duration(seconds: 2));

        // Close the dialog after the delay
        GoBack(context);

        // Get the QR code value
        String? qr_id = scanData.code;

        // Fetch user ID and coupon data based on the QR code
        final user_id = await qrService.fetchQRValidUserId(qr_id ?? '');
        if (user_id != null) {
          // Fetch coupon details using the fetched user ID
          final couponData = await qrService.fetchRewardsById(qr_id ?? '');
          usernameFuture = await _userService.fetchUsername(user_id);

          // Check if coupon data is available
          if (couponData!.isNotEmpty) {
            // Extract coupon details
            String couponName = couponData['coupon_name'];
            String bD = couponData['b_desc'];
            int bReq = couponData['bot_req'];
            String imgCoupon = couponData['img_couponLink'];
            String fD = couponData['f_desc'];
            String impD = couponData['imp_desc'];
            String cId = couponData['coupon_id'];

            // Show the coupon popup with the retrieved data
            _showCouponPopup(context, couponName, bD, bReq, imgCoupon, fD, impD,
                cId, usernameFuture ?? '', user_id);
          } else {
            _showDialog(
                'Unavailable', 'No coupon details found for this QR code.');
          }
        } else {
          _showDialog('Unavailable',
              'This QR code is unavailable. Please try another.');
        }
      });
    });
  }

  void _showUserDetails(dynamic user) {
  final String userId = user['_id'];
  final String realName = user['realName'];
  final String sID = user['sID'];
  final int botLiv = user['botLiv'] ?? 0;
  final int dayBot = user['dayBot'] ?? 0;
  final int monthBot = user['monthBot'] ?? 0;
  final int yearBot = user['yearBot'] ?? 0;
  final int eventBot = user['eventBot'] ?? 0;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: SingleChildScrollView(
              controller: controller,
              child: Column(
                children: [
                  // Pull Bar
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 20),
                    width: 48,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  
                  // Profile Section
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundImage: _getProfileImage(user['profileImg_link']),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user['username'] ?? 'Unknown User',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Section Category Headers Style
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: const Text(
                      'PERSONAL INFORMATION',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Personal Information Content
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _buildInfoRow('User ID', userId),
                          const SizedBox(height: 12),
                          _buildInfoRow('Real Name', realName),
                          const SizedBox(height: 12),
                          _buildInfoRow('Student ID', sID),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Bottle Statistics Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: const Text(
                      'BOTTLE STATISTICS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Bottle Statistics Content
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        _buildStatCard('Total Bottles', botLiv, Colors.green),
                        _buildStatCard('Daily Bottles', dayBot, Colors.blue),
                        _buildStatCard('Monthly Bottles', monthBot, Colors.purple),
                        _buildStatCard('Yearly Bottles', yearBot, Colors.red),
                        _buildStatCard('Event Bottles', eventBot, Colors.orange),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Coupons Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: const Text(
                      'COUPONS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Coupons Content
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber[50],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'Coupon list will be added here',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Widget _buildInfoRow(String label, String value) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.grey,
        ),
      ),
      Text(
        value,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  );
}

Widget _buildStatCard(String label, int value, MaterialColor color) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color[50],
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color[600],
          ),
        ),
      ],
    ),
  );
}

  

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isScanning) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Scan QR Code'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => setState(() => _isScanning = false),
          ),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              flex: 5,
              child: QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
                overlay: QrScannerOverlayShape(
                  borderColor: Colors.white,
                  borderRadius: 10,
                  borderLength: 30,
                  borderWidth: 10,
                  cutOutSize: 300,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0083AB), Color(0xFF003545)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                      onPressed: () => GoBack(context),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Admin',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.qr_code_scanner,
                        color: Colors.white,
                      ),
                      onPressed: _startQRScanner,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onChanged: _filterUsers,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                    : _filteredUsers.isEmpty
                        ? const Center(
                            child: Text(
                              'No users found',
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            itemCount: _filteredUsers.length,
                            itemBuilder: (context, index) {
                              final user = _filteredUsers[index];
                              return GestureDetector(
                                onTap: () => _showUserDetails(user),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 16.0),
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 25,
                                        backgroundImage: _getProfileImage(
                                            user['profileImg_link']),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          user['username'] ?? 'Unknown User',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
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
      String cId,
      String userName,
      String user_id) async {
    
    showDialog(
      context: context,
      barrierDismissible: false,
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
                      Text(
                        'This Coupon is going to be used by \n $userName',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
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
                              useCoupon(cId, user_id);
                              await qrService
                                  .deleteALLQRofThisUser(user_id);
                              GoBack(context);
                              _showDialogAndGoToAdmin(
                                  'Success!', 'This coupon is activated');
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue),
                            child: const Text('Authorize coupon'),
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
