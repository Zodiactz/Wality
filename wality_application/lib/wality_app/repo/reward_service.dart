// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:wality_application/wality_app/repo/user_service.dart';
import 'package:wality_application/wality_app/utils/constant.dart';
import 'package:wality_application/wality_app/views_models/water_save_vm.dart';
import 'package:flutter/material.dart';

final UserService userService = UserService();

class RewardService {
  Future<String?> createCoupon(
    String coupon_name,
    int bot_req,
    String b_desc,
    String f_desc,
    String imp_desc,
    File? imageFile,
    DateTime exp_date) async {
  String? uploadedImageUrl;
  // Generate a random 6-digit qr_id
  final random = Random();
  final coupon_id = (random.nextInt(900000) + 100000)
      .toString(); // Generates a 6-digit number

  if (imageFile != null) {
    uploadedImageUrl = await userService.uploadImage(imageFile);
    if (uploadedImageUrl == null) {
      return 'Failed to upload image.';
    }
  }

  // Convert exp_date to ISO8601 string
  final expDateIso = exp_date!.toIso8601String();

  // Construct the request payload
  final newQRData = {
    "coupon_id": coupon_id,
    "b_desc": b_desc,
    "bot_req": bot_req,
    "coupon_name": coupon_name,
    "f_desc": f_desc,
    "imp_desc": imp_desc,
    "img_couponLink": uploadedImageUrl,
    "exp_date": expDateIso, // Add expiration date to payload
  };

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/createCoupon'), // Replace with your backend URL endpoint for creating QR
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(newQRData),
    );

    if (response.statusCode == 200) {
      // Success: Return the response body if needed
      return coupon_id;
    } else {
      // Failure: Return error message
      return 'Failed to create Coupon: ${response.body}';
    }
  } catch (e) {
    // Exception: Return error message
    return 'Failed to create Coupon: $e';
  }
}


  Future<List<dynamic>> fetchRewards() async {
    final response = await http.get(Uri.parse('$baseUrl/getAllCoupons'));

    // Check if the response status code is 200
    if (response.statusCode == 200) {
      // Check if response body is not null and not empty
      if (response.body != null && response.body.isNotEmpty) {
        try {
          final List<dynamic> rewards = json.decode(response.body);

          // Ensure the decoded response is a list
          if (rewards is List) {
            return rewards; // Return the list if valid
          } else {
            // Handle case where response is not a list
            return []; // Or throw an exception or return a default value
          }
        } catch (e) {
          // Handle JSON decode error
          print('Error decoding JSON: $e');
          return []; // Return an empty list in case of a decode error
        }
      } else {
        // If the response body is empty or null, return an empty list
        return [];
      }
    } else {
      throw Exception(
          'Failed to load rewards, status code: ${response.statusCode}');
    }
  }

  Future<void> deleteCoupon(String coupon_id, String imageURL) async {
    final url = Uri.parse('$baseUrl/deleteCoupon/$coupon_id');

    try {
      final response = await http.delete(url);
      userService.deleteImageFromFirebase(imageURL);
      if (response.statusCode == 200) {
        // Successfully deleted the coupon

        // e.g., 'Coupon deleted successfully!'
      } else if (response.statusCode == 404) {
        // e.g., 'Coupon not found!'
      } else {
        // Other error
      }
    } catch (e) {
      throw Exception('Failed to delete coupon: $e');
    }
  }
}
