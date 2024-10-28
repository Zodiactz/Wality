import 'dart:io';
import 'dart:math';
import 'package:mime/mime.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';
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
      print('Failed to fetch QR id');
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
      print('Failed to fetch QR id');
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
        print("success! QR created: ${response.body}");
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
        final data = jsonDecode(response.body);
        print(data['status']); // e.g., 'QR deleted successfully!'
      } else if (response.statusCode == 404) {
        // User not found
        final data = jsonDecode(response.body);
        print(data['status']); // e.g., 'QR not found!'
      } else {
        // Other error
        final data = jsonDecode(response.body);
        print('Error: ${data['error']}');
      }
    } catch (e) {
      print('Failed to delete QR: $e');
    }
  }

    Future<Map<String, dynamic>?> fetchRewardsByCouponId(String coupon_id) async {
    final response =
        await http.get(Uri.parse('$baseUrl/getRewardByCouponId/$coupon_id'));

    if (response.statusCode == 200) {
      // Assuming your API returns a single reward object
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load reward data');
    }
  }
}
