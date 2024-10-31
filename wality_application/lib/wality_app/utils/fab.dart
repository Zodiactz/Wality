// ignore_for_file: implementation_imports, library_private_types_in_public_api, use_build_context_synchronously, non_constant_identifier_names

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wality_application/wality_app/repo/reward_service.dart';
import 'package:wality_application/wality_app/utils/awesome_snack_bar.dart';
import 'package:wality_application/wality_app/utils/change_pic/CouponCircle.dart';
import 'package:wality_application/wality_app/utils/navigator_utils.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter/src/widgets/async.dart' as flutter_async;
import 'package:http/http.dart' as http;
import 'dart:convert';

class CustomFab extends StatefulWidget {
  const CustomFab({super.key});

  @override
  _CustomFabState createState() => _CustomFabState();
}

class _CustomFabState extends State<CustomFab> {
  final TextEditingController _couponNameController = TextEditingController();
  final TextEditingController _couponBriefDescriptionController =
      TextEditingController();
  final TextEditingController _couponImportanceDescriptionController =
      TextEditingController();
  final TextEditingController _couponBotRequirementController =
      TextEditingController();
  final TextEditingController _couponDescriptionController =
      TextEditingController();

  bool _isCouponNameRequired = false;
  bool _isCouponBriefDescriptionRequired = false;
  bool _isCouponBotRequirementRequired = false;
  bool _isCouponDescriptionRequired = false;

  List<String> couponCheck = [];
  bool isLoading = true;
  Future<int?>? botAmount;
  int? waterAmount;
  String? imgURL = "";
  final RewardService rewardService = RewardService();
  List<dynamic> rewards = [];

  void _updateImageURL(String path) {
    setState(() {
      imgURL = path;
      print('This is imgURL: $imgURL');
    });
  }

  void _showFabOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: 150,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ListTile(
                leading: const Icon(Icons.add, color: Color(0xFF342056)),
                title: const Text('Create Coupon'),
                onTap: () {
                  Navigator.of(context).pop(); // Close the FAB options sheet
                  _showFullScreenBottomSheet(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.list, color: Color(0xFF342056)),
                title: const Text('View Coupons'),
                onTap: () {
                  Navigator.of(context).pop(); // Close the FAB options sheet
                  _showCouponList(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFullScreenBottomSheet(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomSheetHeight = screenHeight * 0.9; // 90% of the screen height

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: bottomSheetHeight,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pull Bar
                    Center(
                      child: Container(
                        width: 48,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),

                    // Title
                    const SizedBox(height: 20),
                    const Text(
                      'Create Coupon',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF342056),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Coupon Image
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          GestureDetector(
                              onTap: () {
                                CouponCircle(onImageUploaded: _updateImageURL);
                              },
                              child: CouponCircle(
                                  onImageUploaded: _updateImageURL)),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                CouponCircle(onImageUploaded: _updateImageURL);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent.withOpacity(0.8),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Coupon Name
                    const Text(
                      'Coupon Name',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF342056),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _couponNameController,
                      decoration: InputDecoration(
                        hintText: 'Enter coupon name',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        errorText: _isCouponNameRequired
                            ? 'Please enter a coupon name'
                            : null,
                        errorStyle: const TextStyle(color: Colors.red),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Bottle Description
                    const Text(
                      'Brief Coupon Description',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF342056),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _couponBriefDescriptionController,
                      decoration: InputDecoration(
                        hintText: 'Enter brief coupon description',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        errorText: _isCouponBriefDescriptionRequired
                            ? 'Please enter a brief coupon description'
                            : null,
                        errorStyle: const TextStyle(color: Colors.red),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Importance Description
                    const Text(
                      'Importance Description',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF342056),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _couponImportanceDescriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Enter importance description (optional)',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Bottle Requirement
                    const Text(
                      'Bottle Requirement',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF342056),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _couponBotRequirementController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter
                            .digitsOnly, // Only allows digits
                      ],
                      decoration: InputDecoration(
                        hintText: 'Enter bottle requirement',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        errorText: _isCouponBotRequirementRequired
                            ? 'Please enter a bottle requirement'
                            : null,
                        errorStyle: const TextStyle(color: Colors.red),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Coupon Description
                    const Text(
                      'Coupon Description',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF342056),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _couponDescriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Enter coupon description',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        errorText: _isCouponDescriptionRequired
                            ? 'Please enter a coupon description'
                            : null,
                        errorStyle: const TextStyle(color: Colors.red),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Create Coupon Button
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          final coupon_name = _couponNameController.text.trim();
                          final bot_req =
                              _couponBotRequirementController.text.trim();
                          final b_desc =
                              _couponBriefDescriptionController.text.trim();
                          final f_desc =
                              _couponDescriptionController.text.trim();
                          final imp_desc =
                              _couponImportanceDescriptionController.text
                                  .trim();
                          final imageFile = File(imgURL ?? '');
                          setState(() {
                            _isCouponNameRequired =
                                _couponNameController.text.isEmpty;
                            _isCouponBriefDescriptionRequired =
                                _couponBriefDescriptionController.text.isEmpty;
                            _isCouponBotRequirementRequired =
                                _couponBotRequirementController.text.isEmpty;
                            _isCouponDescriptionRequired =
                                _couponDescriptionController.text.isEmpty;
                          });

                          if (!_isCouponNameRequired &&
                              !_isCouponBriefDescriptionRequired &&
                              !_isCouponBotRequirementRequired &&
                              !_isCouponDescriptionRequired) {
                            final int? botReq = int.tryParse(
                                bot_req); // Attempt to parse to int
                            try {
                              await rewardService.createCoupon(
                                  coupon_name,
                                  botReq ?? 0,
                                  b_desc,
                                  f_desc,
                                  imp_desc,
                                  imageFile);

                              // Clear fields and close the bottom sheet
                              _clearFields();
                              GoBack(context); // Close the bottom sheet

                              // Optionally show success feedback (e.g., SnackBar)
                              showAwesomeSnackBar(
                                context,
                                "Success",
                                "Coupon created successfully!",
                                ContentType.success,
                              );
                            } catch (e) {
                              // Handle exceptions from the service
                              // Optionally show error feedback (e.g., SnackBar)
                              showAwesomeSnackBar(
                                context,
                                "Error",
                                "Failed to create coupon. Please try again.",
                                ContentType.failure,
                              );
                            } // Close the bottom sheet
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF342056),
                          minimumSize: const Size(200, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Create Coupon',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCouponList(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomSheetHeight = screenHeight * 0.9; // 90% of the screen height

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: bottomSheetHeight,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0083AB), Color(0xFF005678)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pull Bar
                  Center(
                    child: Container(
                      width: 48,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),

                  // Title
                  const SizedBox(height: 20),
                  const Text(
                    'Coupons',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Coupon List
                  Expanded(
                    child: FutureBuilder<List<dynamic>>(
                      future: rewardService
                          .fetchRewards(), // Make sure to fetch updated rewards
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            flutter_async.ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator(
                                  color: Colors.grey));
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}',
                                  style: const TextStyle(color: Colors.grey)));
                        } else if (snapshot.data == null ||
                            snapshot.data!.isEmpty) {
                          return const Center(
                              child: Text('No coupons available',
                                  style: TextStyle(color: Colors.grey)));
                        }

                        // Sort coupons if data is valid
                        final sortedCoupon = snapshot.data!
                          ..sort(
                              (a, b) => a['bot_req'].compareTo(b['bot_req']));

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final coupon = sortedCoupon[index];
                            return _buildRewardItem(
                              context,
                              coupon['coupon_id'],
                              coupon['coupon_name'],
                              coupon['b_desc'],
                              coupon['bot_req'],
                              coupon['img_couponLink'],
                              coupon['f_desc'],
                              coupon['imp_desc'],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
  return GestureDetector(
    onTap: () => _showCouponPopup(
        context, couponName, bD, bReq, imgCoupon, fD, impD, cId),
    child: Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(imgCoupon),
              radius: 25,
            ),
            title: Text(
              couponName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'RobotoCondensed',
              ),
            ),
            subtitle: Text(
              bD,
              style: const TextStyle(
                color: Colors.white70,
                fontFamily: 'RobotoCondensed',
              ),
            ),
            trailing: SizedBox(
              width: 50, // Set a fixed width
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '$bReq',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'RobotoCondensed',
                    ),
                  ),
                  Flexible( // Use Flexible to allow the text to fit
                    child: Transform.translate(
                      offset: const Offset(0, -4), // Adjust the position of the text
                      child: const Text(
                        'Bottles',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12, // Adjust font size if needed
                          fontFamily: 'RobotoCondensed',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
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
  ) async {
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

                      // Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              try {
                                await rewardService.deleteCoupon(
                                    cId, imgCoupon);
                                Navigator.of(context).pop(); // Close the dialog

                                // Refresh the coupon list and update state
                                await refreshCouponList();

                                // Show the SnackBar after the dialog is closed
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Success! Coupon Deleted!"),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } catch (e) {
                                Navigator.of(context).pop(); // Close the dialog
                                print("This is error: $e");

                                // Show error SnackBar
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text("Failed to delete coupon: $e"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            child: const Text('Delete Coupon'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Exit dialog
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

  Future<void> refreshCouponList() async {
    // Fetch the updated list of coupons
    final List<dynamic> updatedRewards = await rewardService.fetchRewards();

    // Update the state to reflect the new rewards
    setState(() {
      // Assuming you have a member variable to hold the rewards
      this.rewards = updatedRewards; // Assign to a member variable
    });
  }

  void _clearFields() {
    _couponNameController.clear();
    _couponBriefDescriptionController.clear();
    _couponImportanceDescriptionController.clear();
    _couponBotRequirementController.clear();
    _couponDescriptionController.clear();
    setState(() {
      imgURL = null;
      _isCouponNameRequired = false;
      _isCouponBriefDescriptionRequired = false;
      _isCouponBotRequirementRequired = false;
      _isCouponDescriptionRequired = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showFabOptions(context),
      backgroundColor: const Color.fromARGB(255, 47, 145, 162),
      shape: const CircleBorder(),
      child: const Icon(
        Icons.wallet_giftcard,
        color: Colors.white,
        size: 24,
      ),
    );
  }
}
