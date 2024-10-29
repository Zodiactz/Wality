import 'package:flutter/material.dart';
import 'package:wality_application/wality_app/utils/navigator_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CustomFab extends StatefulWidget {
  const CustomFab({Key? key}) : super(key: key);

  @override
  _CustomFabState createState() => _CustomFabState();
}

class _CustomFabState extends State<CustomFab> {
  final TextEditingController _couponNameController = TextEditingController();
  final TextEditingController _couponBotRequirementController =
      TextEditingController();
  final TextEditingController _couponDescriptionController =
      TextEditingController();
  File? _couponImage;

  void _showFullScreenBottomSheet(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomSheetHeight = screenHeight * 0.9; // 90% of the screen height

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: bottomSheetHeight / screenHeight,
          minChildSize: bottomSheetHeight / screenHeight,
          maxChildSize: bottomSheetHeight / screenHeight,
          builder: (_, controller) {
            return StatefulBuilder(
              builder: (context, setState) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
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

                      // Title
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Create Coupon',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF342056),
                              ),
                            ),
                            IconButton(
                              onPressed: () => GoBack(context),
                              icon: const Icon(
                                Icons.close,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Expanded(
                        child: SingleChildScrollView(
                          controller: controller,
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Create Coupon Button
                                Center(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // TODO: Implement coupon creation logic
                                      _clearFields();
                                      GoBack(context); // Close the bottom sheet
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
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _clearFields() {
    _couponNameController.clear();
    _couponBotRequirementController.clear();
    _couponDescriptionController.clear();
    setState(() {
      _couponImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showFullScreenBottomSheet(context),
      backgroundColor: const Color.fromARGB(255, 47, 145, 162),
      child: const Icon(
        Icons.add,
        color: Colors.white,
        size: 24,
      ),
      shape: const CircleBorder(),
    );
  }
}