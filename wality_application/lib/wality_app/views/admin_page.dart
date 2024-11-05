// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:wality_application/wality_app/repo/qrValid_service.dart';
import 'package:wality_application/wality_app/repo/reward_service.dart';
import 'package:wality_application/wality_app/utils/constant.dart';
import 'package:wality_application/wality_app/utils/navigator_utils.dart';
import 'package:wality_application/wality_app/repo/user_service.dart';
import 'package:wality_application/wality_app/repo/realm_service.dart';
import 'package:intl/intl.dart';

import 'package:http/http.dart' as http;
import 'package:wality_application/wality_app/utils/fab.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final UserService _userService = UserService();
  final RealmService _realmService = RealmService();
  final RewardService _rewardService = RewardService();
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
  Future<int?>? usedWcoin;
  Future<int?>? currentWcoin;

  @override
  void initState() {
    super.initState();
    currentUserId = _realmService.getCurrentUserId();
    usedWcoin = _userService.fetchUserUsedWcoin(currentUserId!);
    currentWcoin = _userService.fetchUserEventBot(currentUserId!);
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
      setState(() {
        _isLoading = false;
        throw Exception(e);
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
          final realname = (user['realName'] ?? '').toString().toLowerCase();
          return username.contains(query.toLowerCase()) ||
              realname.contains(query.toLowerCase());
        }).toList();
      }
      _sortUsers(_filteredUsers);
    });
  }

  ImageProvider _getProfileImage(String? profileImgLink) {
    if (profileImgLink != null && profileImgLink.isNotEmpty) {
      return NetworkImage(profileImgLink);
    } else {
      return const AssetImage('assets/images/cat.png');
    }
  }

  (String, Color) calculateDaysUntilReCoupon(int repDay, int countStart) {
    int daysLeft = repDay - countStart;

    // Return red color if 3 or fewer days left
    if (daysLeft <= 3) {
      return ('$daysLeft days left', Colors.red);
    }

    return ('$daysLeft days left', Colors.green);
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
                openAdminPage(context);
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
                openAdminPage(context);
                // Resume scanning after dialog is dismissed
                openAdminPage(context);
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

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      // Pause scanning while processing
      controller.pauseCamera();

      // Show dialog indicating scanning
      _showDialogWithAutoDismiss(
        'Scanning',
        'Please wait while we process the QR code...',
      );

      // Ensure the dialog is shown before proceeding
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(const Duration(seconds: 2));

        // Close the dialog after the delay
        openAdminPage(context);

        // Get the QR code value
        String? qr_id = scanData.code;

        // Fetch user ID and coupon data based on the QR code
        if (qr_id != null && qr_id.isNotEmpty) {
          final user_id = await qrService.fetchQRValidUserId(qr_id);

          if (user_id != null) {
            final coupon_id = await qrService.fetchQRValidCouponId(qr_id);
            // Fetch coupon details using the fetched user ID
            final couponData =
                await _userService.fetchRewardsByCouponId(coupon_id!);

            // Ensure couponData is not null
            if (couponData != null && couponData.isNotEmpty) {
              // Extract coupon details
              String couponName = couponData['coupon_name'] ?? 'Unknown';
              String bD = couponData['b_desc'] ?? '';
              int bReq = couponData['bot_req'] ?? 0;
              String imgCoupon = couponData['img_couponLink'] ?? '';
              String fD = couponData['f_desc'] ?? '';
              String impD = couponData['imp_desc'] ?? '';
              String cId = couponData['coupon_id'] ?? '';
              String expD = couponData['exp_date'] ?? '';
              String auAdmin = couponData['authorizedBy'] ?? '';

              // Fetch username based on user ID
              usernameFuture = await _userService.fetchUsername(user_id);

              // Show the coupon popup with the retrieved data
              _showCouponPopup(
                context,
                couponName,
                bD,
                bReq,
                imgCoupon,
                fD,
                impD,
                cId,
                usernameFuture ?? '',
                user_id,
                expD
              );
            } else {
              _showDialog(
                'Unavailable',
                'No coupon details found for this QR code.',
              );
            }
          } else {
            _showDialog(
              'Unavailable',
              'This QR code is unavailable. Please try another.',
            );
          }
        } else {
          _showDialog('Invalid', 'QR code is empty or invalid.');
        }
      });
    });
  }

  void _showUserDetails(dynamic user) {
    final String userId = user['user_id'];
    final String realName = user['realName'];
    final String sID = user['sID'];
    final int totalMl = user['totalMl'] ?? 0;
    final int botLiv = user['botLiv'] ?? 0;
    final int dayBot = user['dayBot'] ?? 0;
    final int monthBot = user['monthBot'] ?? 0;
    final int yearBot = user['yearBot'] ?? 0;
    final int eventBot = user['eventBot'] ?? 0;
    final int currentWcoin = user['currentWcoin'] ?? 0;
    final int usedWcoin = user['usedWcoin'] ?? 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        // Get the screen size
        final screenSize = MediaQuery.of(context).size;
        final initialSize = screenSize.height > 700 ? 0.7 : 0.8;

        return DraggableScrollableSheet(
          initialChildSize: initialSize,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: CustomScrollView(
                controller: controller,
                slivers: [
                  // Pull Bar and Header
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 12, bottom: 8),
                          width: 48,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => GoBack(context),
                              ),
                              Text(
                                'User Details',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(width: 48), // Balance the header
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Profile Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Hero(
                            tag: 'profile-${user['user_id']}',
                            child: CircleAvatar(
                              radius: screenSize.width * 0.12,
                              backgroundImage:
                                  _getProfileImage(user['profileImg_link']),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            user['username'] ?? 'Unknown User',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Personal Information Section
                  SliverToBoxAdapter(
                    child: _buildSection(
                      context,
                      'PERSONAL INFORMATION',
                      Container(
                        width: double
                            .infinity, // Make the container take full width
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(
                              16), // Padding applied to the inner content
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start, // Align to the start
                            children: [
                              // User ID
                              Text(
                                'User ID',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(userId,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium), // Display User ID
                              const SizedBox(height: 12),

                              // Real Name
                              Text(
                                'Real Name',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(realName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium), // Display Real Name
                              const SizedBox(height: 12),

                              // Student ID
                              Text(
                                'Student ID',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(sID,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium), // Display Student ID
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Statistics Grid
                  SliverToBoxAdapter(
                    child: _buildSection(
                      context,
                      'BOTTLE STATISTICS',
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: GridView.extent(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              maxCrossAxisExtent: 200,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 1.5,
                              children: [
                                _buildStatCard(
                                    'Total Milliliter', totalMl, Colors.blue),
                                _buildStatCard(
                                    'Daily Bottles', dayBot, Colors.lime),
                                _buildStatCard(
                                    'Monthly Bottles', monthBot, Colors.purple),
                                _buildStatCard(
                                    'Yearly Bottles', yearBot, Colors.red),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: _buildSection(
                      context,
                      'REWARD STATISTICS',
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: GridView.extent(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              maxCrossAxisExtent: 200,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 1.5,
                              children: [
                                _buildStatCard(
                                    'Total W Coins', eventBot, Colors.yellow),
                                _buildStatCard(
                                    'Used W Coins', usedWcoin, Colors.teal),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Used Coupons Section
                  SliverToBoxAdapter(
                    child: _buildSection(
                      context,
                      'USED COUPONS',
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: FutureBuilder<List<Map<String, dynamic>>?>(
                          future: _userService.fetchCouponHistory(userId),
                          builder: (context, couponCheckSnapshot) {
                            if (couponCheckSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            // Check if there's an error or if data is available
                            if (couponCheckSnapshot.hasError) {
                              print(
                                  'Error fetching coupon history: ${couponCheckSnapshot.error}');
                              return _buildEmptyCouponsCard();
                            }

                            print(
                                'Coupon Check Snapshot Data: ${couponCheckSnapshot.data}'); // Print fetched data

                            List<Map<String, dynamic>> usedCoupons =
                                couponCheckSnapshot.data ?? [];

                            if (usedCoupons.isEmpty) {
                              return _buildEmptyCouponsCard();
                            }

                            return _buildCouponsList(usedCoupons);
                          },
                        ),
                      ),
                    ),
                  ),

                  // Bottom Padding
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 24),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSection(BuildContext context, String title, Widget content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
            ),
          ),
          content,
        ],
      ),
    );
  }

  Widget _buildEmptyCouponsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Text(
          'No coupons used yet',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildCouponsList(List<Map<String, dynamic>> usedCoupons) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: Future.wait(
        usedCoupons.map((coupon) async {
          // Fetch the reward by coupon ID
          final fetchedReward =
              await _userService.fetchRewardsByCouponId(coupon['coupon_id']);

          if (fetchedReward != null) {
            // Merge the 'used_at' field from the coupon into the fetched reward data
            fetchedReward['used_at'] = coupon['used_at'];
          }

          return fetchedReward; // This may return null
        }),
      ).then((results) => results
          .whereType<Map<String, dynamic>>()
          .toList()), // Filter out nulls
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyCouponsCard(); // Adjust this to fit your empty state design
        }

        // Filter and sort coupons
        final sortedCoupons = snapshot.data!
          ..sort((a, b) => (a['bot_req'] ?? 0).compareTo(b['bot_req'] ?? 0));

        if (sortedCoupons.isEmpty) {
          return _buildEmptyCouponsCard(); // No coupons available
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sortedCoupons.length,
          itemBuilder: (context, index) {
            final couponData = sortedCoupons[index];
            print('Coupon data passed to card: $couponData'); // Debug

            return _buildCouponCard(couponData);
          },
        );
      },
    );
  }

  Widget _buildCouponCard(Map<String, dynamic> couponData) {
    // Format the date if it exists and is valid
    final usedAtDate = couponData['used_at'];
    final displayDate = usedAtDate != null
        ? DateFormat('dd/MM/yyyy').format(DateTime.parse(usedAtDate))
        : "No date available";
    final displayTime = usedAtDate != null
        ? DateFormat('HH:mm').format(DateTime.parse(usedAtDate))
        : "No time available";

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber[100]!),
      ),
      child: ListTile(
        onTap: () => _showCouponPopupForAdmin(
          context,
          couponData['coupon_name'] ?? '',
          couponData['b_desc'] ?? '',
          couponData['bot_req'] ?? 0,
          couponData['img_couponLink'] ?? '',
          couponData['f_desc'] ?? '',
          couponData['imp_desc'] ?? '',
          couponData['coupon_id'] ?? '',
          couponData['exp_date'] ?? '',
          couponData['authorizedBy'] ?? '',
        ),
        leading: Hero(
          tag: 'coupon-${couponData['coupon_id']}',
          child: CircleAvatar(
            backgroundImage: NetworkImage(couponData['img_couponLink'] ?? ''),
            backgroundColor: Colors.grey[200],
            onBackgroundImageError: (exception, stackTrace) {
              // Handle image loading errors
            },
          ),
        ),
        title: Text(
          couponData['coupon_name'] ?? 'Unknown Coupon',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              couponData['b_desc'] ?? 'No description available',
              style: TextStyle(color: Colors.grey[600]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: Colors.grey[400],
                ),
                const SizedBox(width: 4),
                Text(
                  "Date: $displayDate Time:$displayTime",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Used',
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
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
                        Icons.chevron_left,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: () => openProfilePage(context),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Admin',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'RobotoCondensed',
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24.0),
                              itemCount: _filteredUsers.length,
                              itemBuilder: (context, index) {
                                final user = _filteredUsers[index];
                                final hasRealName = user['realName'] != null &&
                                    user['realName']
                                        .toString()
                                        .trim()
                                        .isNotEmpty;

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
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                user['username'] ??
                                                    'Unknown User',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              if (hasRealName)
                                                Text(
                                                  user['realName'],
                                                  style: TextStyle(
                                                    color: Colors.white
                                                        .withOpacity(0.7),
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            )),
            ],
          ),
        ),
      ),
      floatingActionButton: const CustomFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
      String user_id,
      String expD) async {
          DateTime dateTime = DateTime.parse(expD);
  String formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);
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
                        'This coupon is going to be used by',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'RobotoCondensed',
                        ),
                      ),
                      Text(
                        userName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
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
                              final userCurrentWcoin = await currentWcoin ?? 0;
                              final beforeSumWcoin = await usedWcoin ?? 0;
                              final sumUserEventBot = userCurrentWcoin - bReq;
                              final sumUsedWcoin = beforeSumWcoin + bReq;
                              _rewardService.useCoupon(context, cId, user_id);
                              _userService.updateUserEventBot(
                                  user_id, sumUserEventBot);
                              _rewardService.updateCouponToHistory(
                                  context, cId, user_id);
                              _userService.updateUserUsedWcoin(
                                  user_id, sumUsedWcoin);
                              await qrService.deleteALLQRofThisUser(user_id);
                              openAdminPage(context);
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

    Future<void> _showCouponPopupForAdmin(
    BuildContext context,
    String couponName,
    String bD,
    int bReq,
    String imgCoupon,
    String fD,
    String impD,
    String cId,
    String expD,
    String byAdmin) async {
  DateTime dateTime = DateTime.parse(expD);
  String formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);

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
                      Text(
                        'This coupon is authorized by $byAdmin',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
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
}
