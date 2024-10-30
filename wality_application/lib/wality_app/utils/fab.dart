// ignore_for_file: implementation_imports, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:wality_application/wality_app/utils/navigator_utils.dart';
import 'package:image_picker/image_picker.dart';
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
  final TextEditingController _couponBottleDescriptionController =
      TextEditingController();
  final TextEditingController _couponImportanceDescriptionController =
      TextEditingController();
  final TextEditingController _couponBotRequirementController =
      TextEditingController();
  final TextEditingController _couponDescriptionController =
      TextEditingController();
  File? _couponImage;

  bool _isCouponNameRequired = false;
  bool _isCouponBottleDescriptionRequired = false;
  bool _isCouponBotRequirementRequired = false;
  bool _isCouponDescriptionRequired = false;

  List<String> couponCheck = [];
  bool isLoading = true;
  Future<int?>? botAmount;
  int? waterAmount;

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
                      child: GestureDetector(
                        onTap: () async {
                          final pickedImage = await ImagePicker()
                              .pickImage(source: ImageSource.gallery);
                          if (pickedImage != null) {
                            setState(() {
                              _couponImage = File(pickedImage.path);
                            });
                          }
                        },
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF342056),
                              width: 2,
                            ),
                            image: _couponImage != null
                                ? DecorationImage(
                                    image: FileImage(_couponImage!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _couponImage == null
                              ? Icon(
                                  Icons.add_a_photo,
                                  color: Colors.grey[600],
                                  size: 40,
                                )
                              : null,
                        ),
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
                      'Bottle Description',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF342056),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _couponBottleDescriptionController,
                      decoration: InputDecoration(
                        hintText: 'Enter bottle description',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        errorText: _isCouponBottleDescriptionRequired
                            ? 'Please enter a bottle description'
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
                        onPressed: () {
                          setState(() {
                            _isCouponNameRequired =
                                _couponNameController.text.isEmpty;
                            _isCouponBottleDescriptionRequired =
                                _couponBottleDescriptionController.text.isEmpty;
                            _isCouponBotRequirementRequired =
                                _couponBotRequirementController.text.isEmpty;
                            _isCouponDescriptionRequired =
                                _couponDescriptionController.text.isEmpty;
                          });

                          if (!_isCouponNameRequired &&
                              !_isCouponBottleDescriptionRequired &&
                              !_isCouponBotRequirementRequired &&
                              !_isCouponDescriptionRequired) {
                            _clearFields();
                            GoBack(context); // Close the bottom sheet
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
                      future: fetchRewards(),
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
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(
                              child: Text('No coupons available',
                                  style: TextStyle(color: Colors.grey)));
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final coupon = snapshot.data![index];
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

  Future<List<dynamic>> fetchRewards() async {
    final response =
        await http.get(Uri.parse('http://localhost:8080/getAllCoupons'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load rewards');
    }
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

  Future<void> _showCouponPopup(
      BuildContext context,
      String couponName,
      String bD,
      int bReq,
      String imgCoupon,
      String fD,
      String impD,
      String cId) async {
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

                      const SizedBox(height: 20),

                      // Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () async {},
                            child: const Text('Delete Coupon'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              GoBack(context);
                            },
                            child: const Text('Exit'),
                          ),
                        ],
                      ),

                      // Buttons
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

  void _clearFields() {
    _couponNameController.clear();
    _couponBottleDescriptionController.clear();
    _couponImportanceDescriptionController.clear();
    _couponBotRequirementController.clear();
    _couponDescriptionController.clear();
    setState(() {
      _couponImage = null;
      _isCouponNameRequired = false;
      _isCouponBottleDescriptionRequired = false;
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
        Icons.add,
        color: Colors.white,
        size: 24,
      ),
    );
  }
}
