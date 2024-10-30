// ignore_for_file: non_constant_identifier_names, file_names

import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:wality_application/wality_app/utils/constant.dart';

class QRValidService {
  Future<String?> fetchQRValidUserId(String qr_id) async {
    final response =
        await http.get(Uri.parse('$baseUrl/getQRValidByQRId/$qr_id'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data['user_id'];
    } else {
      return null;
    }
  }

  Future<String?> fetchQRValidCouponId(String qr_id) async {
    final response =
        await http.get(Uri.parse('$baseUrl/getQRValidByQRId/$qr_id'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data['coupon_id'];
    } else {
      return null;
    }
  }

  Future<String?> createQR(String user_id, String coupon_id) async {
    // Generate a random 6-digit qr_id
    final random = Random();
    final qr_id = (random.nextInt(900000) + 100000)
        .toString(); // Generates a 6-digit number

    // Construct the request payload
    final newQRData = {
      "qr_id": qr_id,
      "user_id": user_id,
      "coupon_id": coupon_id,
    };

    try {
      final response = await http.post(
        Uri.parse(
            '$baseUrl/createQRValid'), // Replace with your backend URL endpoint for creating QR
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(newQRData),
      );

      if (response.statusCode == 200) {
        // Success: Return the response body if needed
        return qr_id;
      } else {
        // Failure: Return error message
        return 'Failed to create QR data: ${response.body}';
      }
    } catch (e) {
      // Exception: Return error message
      return 'Failed to create QR: $e';
    }
  }

  Future<void> deleteALLQRofThisUser(String userId) async {
    final url = Uri.parse('$baseUrl/deleteAllQR/$userId');

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        // Successfully deleted the user
    
        // e.g., 'QR deleted successfully!'
      } else if (response.statusCode == 404) {
        // User not found
      
        // e.g., 'QR not found!'
      } else {
        // Other error
      }
    } catch (e) {
      throw Exception('Failed to load reward data');
    }
  }

  Future<Map<String, dynamic>?> fetchRewardsByQRId(String qr_id) async {
    final response =
        await http.get(Uri.parse('$baseUrl/getQRValidByQRId/$qr_id'));

    if (response.statusCode == 200) {
      // Assuming your API returns a single reward object
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load reward data');
    }
  }
}
