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

import 'package:wality_application/wality_app/views_models/coupon_vm.dart';

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

  final _formKey = GlobalKey<FormState>();

  final CouponViewModel _couponViewModel =
      CouponViewModel(); // Instantiate ViewModel

  List<String> couponCheck = [];
  bool isLoading = true;
  Future<int?>? botAmount;
  int? waterAmount;
  String? imgURL;
  final RewardService rewardService = RewardService();
  List<dynamic> rewards = [];

  @override
  void initState() {
    super.initState();
    // Add listeners for real-time validation
    _couponNameController.addListener(() {
      _couponViewModel.setcouponNameError(
          _couponViewModel.validateCouponName(_couponNameController.text));
    });
    _couponBriefDescriptionController.addListener(() {
      _couponViewModel.setBriefDescriptionError(_couponViewModel
          .validateBriefDescription(_couponBriefDescriptionController.text));
    });
    _couponImportanceDescriptionController.addListener(() {
      _couponViewModel.setImportanceDescriptionError(
          _couponViewModel.validateImportanceDescription(
              _couponImportanceDescriptionController.text));
    });
    _couponBotRequirementController.addListener(() {
      _couponViewModel.setBotRequirementError(_couponViewModel
          .validateBotRequirement(_couponBotRequirementController.text));
    });
    _couponDescriptionController.addListener(() {
      _couponViewModel.setDescriptionError(_couponViewModel
          .validateDescription(_couponDescriptionController.text));
    });
  }

  bool _isFormValid() {
    return _couponViewModel.validateAllCouponFields(
      name: _couponNameController.text,
      briefDescription: _couponBriefDescriptionController.text,
      importanceDescription: _couponImportanceDescriptionController.text,
      botRequirement: _couponBotRequirementController.text,
      description: _couponDescriptionController.text,
    );
  }

  @override
  void dispose() {
    _couponNameController.dispose();
    _couponBriefDescriptionController.dispose();
    _couponImportanceDescriptionController.dispose();
    _couponBotRequirementController.dispose();
    _couponDescriptionController.dispose();
    super.dispose();
  }

  // Submit method to validate and show errors
  void _submitCoupon() {
    final isValid = _couponViewModel.validateAllCouponFields(
      name: _couponNameController.text,
      briefDescription: _couponBriefDescriptionController.text,
      importanceDescription: _couponImportanceDescriptionController.text,
      botRequirement: _couponBotRequirementController.text,
      description: _couponDescriptionController.text,
    );

    if (isValid) {
      // Proceed with coupon submission logic
    } else {
      setState(() {}); // Update UI to show validation errors
    }
  }

  void _updateImageURL(String path) {
    setState(() {
      imgURL = path;
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
    final bottomSheetHeight = screenHeight * 0.9;

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
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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

                      // Image Upload Section
                      Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            GestureDetector(
                                onTap: () {
                                  CouponCircle(
                                      onImageUploaded: _updateImageURL);
                                },
                                child: CouponCircle(
                                    onImageUploaded: _updateImageURL)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Coupon Name Field
                      const Text(
                        'Coupon Name',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF342056),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _couponNameController,
                        decoration: InputDecoration(
                          hintText: 'Enter coupon name',
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          errorText: _couponViewModel.couponNameError,
                          errorStyle: const TextStyle(color: Colors.red),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Brief Description Field
                      const Text(
                        'Brief Coupon Description',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF342056),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _couponBriefDescriptionController,
                        decoration: InputDecoration(
                          hintText: 'Enter brief coupon description',
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          errorText:
                              _couponViewModel.couponBriefDescriptionError,
                          errorStyle: const TextStyle(color: Colors.red),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Importance Description Field
                      const Text(
                        'Importance Description',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF342056),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
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

                      // Bottle Requirement Field
                      const Text(
                        'Bottle Requirement',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF342056),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _couponBotRequirementController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: InputDecoration(
                          hintText: 'Enter bottle requirement',
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          errorText: _couponViewModel.couponBotRequirementError,
                          errorStyle: const TextStyle(color: Colors.red),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Coupon Description Field
                      const Text(
                        'Coupon Description',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF342056),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
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
                          errorText: _couponViewModel.couponDescriptionError,
                          errorStyle: const TextStyle(color: Colors.red),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      Center(
                        child: ElevatedButton(
                          onPressed: _isFormValid()
                              ? () async {
                                  try {
                                    final coupon_name =
                                        _couponNameController.text.trim();
                                    final bot_req =
                                        _couponBotRequirementController.text
                                            .trim();
                                    final b_desc =
                                        _couponBriefDescriptionController.text
                                            .trim();
                                    final f_desc = _couponDescriptionController
                                        .text
                                        .trim();
                                    final imp_desc =
                                        _couponImportanceDescriptionController
                                            .text
                                            .trim();
                                    final imageFile = File(imgURL ?? '');

                                    final int? botReq = int.tryParse(bot_req);
                                    await rewardService.createCoupon(
                                        coupon_name,
                                        botReq ?? 0,
                                        b_desc,
                                        f_desc,
                                        imp_desc,
                                        imageFile);

                                    _clearFields();
                                    GoBack(context);

                                    showAwesomeSnackBar(
                                      context,
                                      "Success",
                                      "Coupon created successfully!",
                                      ContentType.success,
                                    );
                                  } catch (e) {
                                    showAwesomeSnackBar(
                                      context,
                                      "Error",
                                      "Failed to create coupon. Please try again.",
                                      ContentType.failure,
                                    );
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isFormValid()
                                ? const Color(0xFF342056)
                                : Colors.grey,
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
                    child: StreamBuilder<List<dynamic>>(
                      stream: Stream.fromFuture(
                          rewardService.fetchRewards()), // Use the stream here
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
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
                          itemCount: sortedCoupon.length,
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
                    Flexible(
                      // Use Flexible to allow the text to fit
                      child: Transform.translate(
                        offset: const Offset(
                            0, -4), // Adjust the position of the text
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
                              // Show a loading indicator if desired

                              try {
                                // Attempt to delete the coupon
                                await rewardService.deleteCoupon(
                                    cId, imgCoupon);

                                // Close the dialog once the coupon is deleted successfully
                                Navigator.of(context).pop();

                                // Refresh the coupon list asynchronously
                                await refreshCouponList();

                                // Update the widget's state after refreshing the list
                                setState(() {});

                                showAwesomeSnackBar(
                                  context,
                                  "Success",
                                  "Success! Coupon Deleted!",
                                  ContentType.success,
                                );

                                // Navigate back to the admin page after the success message
                                openAdminPage(context);
                              } catch (e) {
                                // Handle errors and close the dialog
                                openAdminPage(context);
                                print("This is error: $e");

                                // Show error message

                                showAwesomeSnackBar(
                                  context,
                                  "Error",
                                  "Failed to delete coupon!",
                                  ContentType.success,
                                );
                              }
                            },
                            child: const Text('Delete Coupon'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                             openAdminPage(context); // Exit dialog without action
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
