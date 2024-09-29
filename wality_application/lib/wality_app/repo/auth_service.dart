import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:wality_application/wality_app/models/user.dart';
import 'package:wality_application/wality_app/utils/constant.dart';

class AuthService {
  Future<String?> createUser(Users newUser) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/create'), // Replace with your backend URL
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(newUser.toJson()),
      );

      if (response.statusCode == 200) {
        // Success: Return the response body if needed
        return response.body;
      } else {
        // Failure: Return error message
        return 'Failed to create user data: ${response.body}';
      }
    } catch (e) {
      // Exception: Return error message
      return 'Failed to sign up: $e';
    }
  }

}
