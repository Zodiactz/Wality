import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wality_application/wality_app/repo/realm_service.dart';
import 'package:wality_application/wality_app/repo/reward_service.dart';
import 'package:wality_application/wality_app/repo/user_service.dart';
import 'package:wality_application/wality_app/utils/awesome_snack_bar.dart';
import 'package:wality_application/wality_app/utils/change_pic/CouponCircle.dart';
import 'package:wality_application/wality_app/utils/navigator_utils.dart';
import 'dart:io';
import 'dart:async';
import 'package:wality_application/wality_app/views_models/coupon_vm.dart';
import 'package:intl/src/intl/date_format.dart';

class CustomFab extends StatefulWidget {
  const CustomFab({super.key});

  @override
  _CustomFabState createState() => _CustomFabState();
}

class _CustomFabState extends State<CustomFab> {
  // TextEditingControllers
  final TextEditingController _couponNameController = TextEditingController();
  final TextEditingController _couponBriefDescriptionController =
      TextEditingController();
  final TextEditingController _couponImportanceDescriptionController =
      TextEditingController();
  final TextEditingController _couponBotRequirementController =
      TextEditingController();
  final TextEditingController _couponDescriptionController =
      TextEditingController();
  final TextEditingController _replenishController = TextEditingController();

  // FocusNodes
  final FocusNode _couponNameFocus = FocusNode();
  final FocusNode _couponBriefDescriptionFocus = FocusNode();
  final FocusNode _couponImportanceDescriptionFocus = FocusNode();
  final FocusNode _couponBotRequirementFocus = FocusNode();
  final FocusNode _couponDescriptionFocus = FocusNode();
  final FocusNode _replenishFocus = FocusNode();

  DateTime? _expirationDate;
  final _formKey = GlobalKey<FormState>();
  final CouponViewModel _couponViewModel = CouponViewModel();
  final ValueNotifier<bool> _isDatePickerOpen = ValueNotifier<bool>(false);

  List<String> couponCheck = [];
  bool isLoading = true;
  Future<int?>? botAmount;
  Future<String?>? adminRealName;
  int? waterAmount;
  String? imgURL;
  final String defaultImagePath = 'assets/images/coupon_lnwza.png';
  final RewardService rewardService = RewardService();
  List<dynamic> rewards = [];
  final UserService userService = UserService();
  final RealmService realmService = RealmService();
  String? currentUserId;

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
    currentUserId = realmService.getCurrentUserId();
    adminRealName = userService.fetchRealName(currentUserId!);
  }

  @override
  void dispose() {
    // Dispose of TextEditingControllers
    _couponNameController.dispose();
    _couponBriefDescriptionController.dispose();
    _couponImportanceDescriptionController.dispose();
    _couponBotRequirementController.dispose();
    _couponDescriptionController.dispose();
    _replenishController.dispose();

    // Dispose of FocusNodes
    _couponNameFocus.dispose();
    _couponBriefDescriptionFocus.dispose();
    _couponImportanceDescriptionFocus.dispose();
    _couponBotRequirementFocus.dispose();
    _couponDescriptionFocus.dispose();
    _replenishFocus.dispose();

    _isDatePickerOpen.dispose();
    super.dispose();
  }

  bool _isFormValid() {
    return _couponViewModel.validateAllCouponFields(
          name: _couponNameController.text,
          briefDescription: _couponBriefDescriptionController.text,
          importanceDescription: _couponImportanceDescriptionController.text,
          botRequirement: _couponBotRequirementController.text,
          description: _couponDescriptionController.text,
          replenish: _replenishController.text, // Add replenish validation
        ) &&
        _expirationDate != null;
  }

  // Submit method to validate and show errors
  void _submitCoupon() {
    final isValid = _couponViewModel.validateAllCouponFields(
      name: _couponNameController.text,
      briefDescription: _couponBriefDescriptionController.text,
      importanceDescription: _couponImportanceDescriptionController.text,
      botRequirement: _couponBotRequirementController.text,
      description: _couponDescriptionController.text,
      replenish: _replenishController.text,
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

  (String, Color) calculateDaysUntilReCoupon(int repDay, int countStart) {
    int daysLeft = repDay - countStart;

    // Return red color if 3 or fewer days left
    if (daysLeft <= 3) {
      return ('$daysLeft days left', Colors.red);
    }
    print(daysLeft);

    return ('$daysLeft days left', Colors.green);
  }

  void _showFabOptions(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return Container(
        // Using automatic height based on content
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        // Wrap with SingleChildScrollView to prevent overflow
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Use minimum space needed
            children: [
              // Pull bar indicator
              Container(
                width: 48,
                height: 4,
                margin: const EdgeInsets.only(bottom: 8.0),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
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
              ListTile(
                leading: const Icon(Icons.shopping_bag, color: Color(0xFF342056)),
                title: const Text('Shop'),
                onTap: () {
                  Navigator.of(context).pop(); // Close the FAB options sheet
                  _showShop(context);
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

  
  Future<File> getImageFile() async {
    if (imgURL != null) {
      return File(imgURL!);
    } else {
      // Create a temporary file from the asset
      final byteData = await rootBundle.load(defaultImagePath);
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/default_coupon_image.png';
      final tempFile = File(tempPath);
      await tempFile.writeAsBytes(byteData.buffer.asUint8List());
      return tempFile;
    }
  }

  void _showFullScreenBottomSheet(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomSheetHeight = screenHeight * 0.9;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return ValueListenableBuilder<bool>(
          valueListenable: _isDatePickerOpen,
          builder: (context, isDatePickerOpen, child) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: isDatePickerOpen ? 80.0 : 0.0,
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
                            focusNode: _couponNameFocus,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(_couponBriefDescriptionFocus);
                            },
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
                            focusNode: _couponBriefDescriptionFocus,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(_couponBotRequirementFocus);
                            },
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

                          // Bottle Requirement Field
                          const Text(
                            'Coin Requirement',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF342056),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _couponBotRequirementController,
                            focusNode: _couponBotRequirementFocus,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(_couponDescriptionFocus);
                            },
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: InputDecoration(
                              hintText: 'Enter Coin requirement',
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              errorText:
                                  _couponViewModel.couponBotRequirementError,
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
                            focusNode: _couponDescriptionFocus,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context).requestFocus(
                                  _couponImportanceDescriptionFocus);
                            },
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Enter coupon description',
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              errorText:
                                  _couponViewModel.couponDescriptionError,
                              errorStyle: const TextStyle(color: Colors.red),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Highlight Description Field
                          const Text(
                            'Highlight Description',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF342056),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _couponImportanceDescriptionController,
                            focusNode: _couponImportanceDescriptionFocus,
                            maxLines: 3,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(_replenishFocus);
                            },
                            decoration: InputDecoration(
                              hintText:
                                  'Enter highlight texts in the description (optional)',
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Replenish Amount Field
                          const Text(
                            'Replenish frequency date',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF342056),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _replenishController,
                            focusNode: _replenishFocus,
                            onFieldSubmitted: (value) {
                              FocusScope.of(context).unfocus();
                            },
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: InputDecoration(
                              hintText: 'Enter replenish frequency (minimum 1)',
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              errorText: _couponViewModel.replenishError,
                              errorStyle: const TextStyle(color: Colors.red),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Expiration Date Field
                          const Text(
                            'Expiration Date',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF342056),
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {
                              _selectDate(context);
                              FocusScope.of(context).unfocus();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 15),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _expirationDate == null
                                        ? 'Select expiration date'
                                        : '${_expirationDate!.day}/${_expirationDate!.month}/${_expirationDate!.year}',
                                    style: TextStyle(
                                      color: _expirationDate == null
                                          ? Colors.grey[600]
                                          : Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const Icon(Icons.calendar_today,
                                      color: Color(0xFF342056)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

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
                                            _couponBriefDescriptionController
                                                .text
                                                .trim();
                                        final f_desc =
                                            _couponDescriptionController.text
                                                .trim();
                                        final imp_desc =
                                            _couponImportanceDescriptionController
                                                .text
                                                .trim();
                                        final replenish =
                                            _replenishController.text.trim();
                                        final imageFile = await getImageFile();
                                        final expirationDate = _expirationDate;

                                        final int? botReq =
                                            int.tryParse(bot_req);
                                        final int? replenishAmount =
                                            int.tryParse(replenish);
                                        final adminName =
                                            await adminRealName ?? '';

                                        await rewardService.createCoupon(
                                            coupon_name,
                                            botReq ?? 0,
                                            b_desc,
                                            f_desc,
                                            imp_desc,
                                            imageFile,
                                            expirationDate,
                                            replenishAmount ?? 1,
                                            adminName);

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
                                coupon['exp_date']);
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

  void _showShop(BuildContext context) {
  final List<Map<String, dynamic>> _shops = [
    {
      'shop_name': 'Green Bean Cafe',
      'profileImg_link': 'https://example.com/images/shop1.jpg',
      'shop_id': 'shop1',
    },
    {
      'shop_name': 'Lung num shop',
      'profileImg_link': 'https://example.com/images/shop2.jpg',
      'shop_id': 'shop2',
    },
    {
      'shop_name': 'Lung A shop',
      'profileImg_link': 'https://example.com/images/shop3.jpg',
      'shop_id': 'shop3',
    },
    {
      'shop_name': 'Lung B shop',
      'profileImg_link': 'https://example.com/images/shop4.jpg',
      'shop_id': 'shop4',
    },
    {
      'shop_name': 'Lung C shop',
      'profileImg_link': 'https://example.com/images/shop5.jpg',
      'shop_id': 'shop5',
    }
  ];

  List<Map<String, dynamic>> _filteredShops = List.from(_shops);
  TextEditingController searchController = TextEditingController();

  void _filterShops(String query) {
    if (query.isEmpty) {
      _filteredShops = List.from(_shops);
    } else {
      _filteredShops = _shops.where((shop) {
        final shopName = (shop['shop_name'] ?? '').toString().toLowerCase();
        return shopName.contains(query.toLowerCase());
      }).toList();
    }
  }

  ImageProvider _getProfileImage(String? profileImgLink) {
    if (profileImgLink != null && profileImgLink.isNotEmpty) {
      return NetworkImage(profileImgLink);
    } else {
      return const AssetImage('assets/images/store.png');
    }
  }

  // Helper method to build year filter tabs
  Widget _buildYearFilterTab(String year, String selectedYear, VoidCallback onTap, BuildContext context) {
    final isSelected = year == selectedYear;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0083AB) : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF0083AB) : Colors.grey.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          year,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  void _showShopMonthlyWCoinReport(BuildContext context, Map<String, dynamic> shop) {
    // Sample data for monthly WCoin totals
    final List<Map<String, dynamic>> monthlyData = [
      {'month': '04-2025', 'wcoins': 1250},
      {'month': '03-2025', 'wcoins': 980},
      {'month': '02-2025', 'wcoins': 1430},
      {'month': '01-2025', 'wcoins': 875},
      {'month': '12-2024', 'wcoins': 1560},
      {'month': '11-2024', 'wcoins': 1210},
      {'month': '10-2024', 'wcoins': 990},
      {'month': '09-2024', 'wcoins': 1080},
      {'month': '08-2024', 'wcoins': 1340},
      {'month': '07-2024', 'wcoins': 760},
      {'month': '06-2024', 'wcoins': 1120},
      {'month': '05-2024', 'wcoins': 940},
    ];

    // Filter state
    List<Map<String, dynamic>> filteredMonthlyData = List.from(monthlyData);
    String selectedYear = '2025';
    
    // Calculate available screen height for proper sizing
    final screenHeight = MediaQuery.of(context).size.height;
    final availableHeight = screenHeight - 80; // Subtract some padding to avoid overflow
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            
            // Filter function for year selection
            void filterByYear(String year) {
              setState(() {
                selectedYear = year;
                if (year == 'All') {
                  filteredMonthlyData = List.from(monthlyData);
                } else {
                  filteredMonthlyData = monthlyData
                      .where((data) => data['month'].toString().endsWith(year))
                      .toList();
                }
              });
            }
            
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              // Fix: Set the insetPadding to ensure enough space around the dialog
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: SingleChildScrollView(
                // Fix: Wrap with SingleChildScrollView to ensure scrolling if dialog is too tall
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  padding: const EdgeInsets.all(20),
                  // Fix: Use constraints instead of fixed height to respect screen size
                  constraints: BoxConstraints(
                    maxHeight: availableHeight,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header with shop info
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: _getProfileImage(shop['profileImg_link']),
                            radius: 25,
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  shop['shop_name'],
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Monthly WCoin Report',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Year filter tabs
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildYearFilterTab('All', selectedYear, () => filterByYear('All'), context),
                            _buildYearFilterTab('2025', selectedYear, () => filterByYear('2025'), context),
                            _buildYearFilterTab('2024', selectedYear, () => filterByYear('2024'), context),
                            _buildYearFilterTab('2023', selectedYear, () => filterByYear('2023'), context),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      
                      // Monthly data list - Fix: Use Flexible instead of ConstrainedBox
                      Flexible(
                        child: filteredMonthlyData.isEmpty
                            ? const Center(
                                child: Text(
                                  'No data available for selected year',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                // Fix: Add physics to ensure proper scrolling when content is too large
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount: filteredMonthlyData.length,
                                itemBuilder: (context, index) {
                                  final data = filteredMonthlyData[index];
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(0xFF0083AB).withOpacity(0.1),
                                          const Color(0xFF005678).withOpacity(0.2),
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFF0083AB).withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.calendar_month,
                                              color: Color(0xFF0083AB),
                                              size: 22,
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              data['month'],
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.monetization_on,
                                              color: Color(0xFF342056),
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '${data['wcoins']} WCoins',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF342056),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Total for selected period
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF342056).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF342056).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total WCoins',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${filteredMonthlyData.fold(0, (sum, item) => sum + (item['wcoins'] as int))} WCoins',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF342056),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),

                      // Cut-off button for selected month
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: OutlinedButton.icon(
                          onPressed: filteredMonthlyData.isEmpty 
                              ? null 
                              : () {
                                  // Show confirmation dialog before cutting off
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      // Get current month to show in confirmation
                                      String currentMonth = '';
                                      if (selectedYear != 'All' && filteredMonthlyData.isNotEmpty) {
                                        // Get the first month in filtered data for display
                                        currentMonth = filteredMonthlyData.first['month'];
                                      }
                                      
                                      return AlertDialog(
                                        title: const Text('Confirm Cut-off'),
                                        content: Text(
                                          selectedYear == 'All'
                                              ? 'Are you sure you want to cut off WCoin balance for all months? This action cannot be undone.'
                                              : 'Are you sure you want to cut off WCoin balance for ${currentMonth.isEmpty ? selectedYear : currentMonth}? This action cannot be undone.'
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(),
                                            child: const Text('Cancel'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              // Close confirmation dialog
                                              Navigator.of(context).pop();
                                              
                                              // Show success message
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    selectedYear == 'All'
                                                        ? 'Cut-off completed for all months'
                                                        : 'Cut-off completed for ${currentMonth.isEmpty ? selectedYear : currentMonth}'
                                                  ),
                                                  backgroundColor: Colors.green,
                                                  duration: const Duration(seconds: 2),
                                                ),
                                              );
                                              
                                              // In a real app, perform database update/reset here
                                              // Example: resetBalance(shop['shop_id'], selectedYear, currentMonth);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                            ),
                                            child: const Text('Confirm Cut-off'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(
                              color: filteredMonthlyData.isEmpty 
                                  ? Colors.grey.withOpacity(0.5) 
                                  : Colors.red,
                              width: 1.5,
                            ),
                            foregroundColor: filteredMonthlyData.isEmpty 
                                ? Colors.grey 
                                : Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.money_off),
                          label: const Text(
                            'Cut-off Balance for Selected Period',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      
                      // Close button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0083AB),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            'Close',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Fix: Get screen height minus status bar height to avoid bottom overflow
  final screenHeight = MediaQuery.of(context).size.height;
  final statusBarHeight = MediaQuery.of(context).padding.top;
  final bottomSheetHeight = screenHeight - statusBarHeight;
  
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              // Fix: Use FractionallySizedBox to make sure bottom sheet doesn't exceed screen height
              height: bottomSheetHeight * 0.85,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0083AB), Color(0xFF003545)],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: SafeArea(
                // Fix: Set bottom to false to avoid double padding at the bottom
                bottom: false,
                child: Column(
                  children: [
                    // Pull Bar and Header
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Pull Bar
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            width: 48,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          // Header
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                              const Expanded(
                                child: Center(
                                  child: Text(
                                    'Shops',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'RobotoCondensed',
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 48), // Balance the header
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Search Field
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
                            hintText: 'Search shops...',
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
                          onChanged: (value) {
                            setState(() {
                              _filterShops(value);
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Shop List - With tap functionality to show WCoin report
                    Expanded(
                      child: _filteredShops.isEmpty
                          ? const Center(
                              child: Text(
                                'No shops found',
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                          : ListView.builder(
                              // Fix: Add padding at the bottom of the list to ensure last item is visible
                              padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 16.0),
                              itemCount: _filteredShops.length,
                              itemBuilder: (context, index) {
                                final shop = _filteredShops[index];
                                
                                return GestureDetector(
                                  onTap: () {
                                    // Close the shops bottom sheet first
                                    Navigator.pop(context);
                                    // Then show the monthly WCoin report popup
                                    _showShopMonthlyWCoinReport(context, shop);
                                  },
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
                                              shop['profileImg_link']),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Text(
                                            shop['shop_name'] ?? 'Unknown Shop',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        const Icon(
                                          Icons.arrow_forward_ios,
                                          color: Colors.white70,
                                          size: 16,
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
        },
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
    String expD,
  ) {
    return GestureDetector(
      onTap: () => _showCouponPopup(
          context, couponName, bD, bReq, imgCoupon, fD, impD, cId, expD),
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
                          'Coins',
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
    String expD,
  ) async {
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
                              future: rewardService.fetchRewardById(cId),
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
                        const SizedBox(height: 20),
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
                                GoBack(context); // Exit dialog without action
                              },
                              child: const Text('Exit'),
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
      _expirationDate = null; // Clear expiration date
    });
  }

  // Update the _selectDate method
  Future<void> _selectDate(BuildContext context) async {
    // Unfocus any currently focused field to hide the keyboard
    FocusScope.of(context).unfocus();

    _isDatePickerOpen.value = true;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _expirationDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF342056),
              onPrimary: Colors.white,
              onSurface: Color(0xFF342056),
            ),
          ),
          child: child!,
        );
      },
    );

    _isDatePickerOpen.value = false;

    Future.delayed(const Duration(milliseconds: 1), () {
      FocusScope.of(context).unfocus();
    });

    if (picked != null && picked != _expirationDate) {
      setState(() {
        _expirationDate = picked;
      });
    }
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
