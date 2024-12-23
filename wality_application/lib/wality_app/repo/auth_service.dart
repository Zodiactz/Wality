import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:wality_application/wality_app/models/user.dart';
import 'package:wality_application/wality_app/utils/constant.dart';
import 'package:path_provider/path_provider.dart';

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

  Future<String?> updateUserEmail(String userId, String newEmail) async {
    final String url =
        '$baseUrl/updateEmail/$userId'; // Replace with actual URL

    Map<String, String> requestBody = {
      'email': newEmail,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
      } else {
        throw Exception('Failed to update email: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating email: $e');
    }
    return null;
  }

  // Method to request a password reset link (Step 1)
  Future<String?> requestPasswordReset(String email) async {
    try {
      final response = await http.post(
        Uri.parse(
            '$baseUrl/reset-password'), // Replace with your backend URL for password reset request
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        // Success: Return success message
        return 'Password reset link sent to your email';
      } else {
        // Failure: Return error message
        return 'Failed to send reset link: ${response.body}';
      }
    } catch (e) {
      // Exception: Return error message
      return 'Error sending reset link: $e';
    }
  }

  // Method to reset the password with the provided token and new password (Step 2)
  Future<String?> resetPassword(String token, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse(
            '$baseUrl/reset-password/confirm'), // Replace with your backend URL for password reset confirmation
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'token': token,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        // Success: Return success message
        return 'Password has been reset successfully';
      } else {
        // Failure: Return error message
        return 'Failed to reset password: ${response.body}';
      }
    } catch (e) {
      // Exception: Return error message
      return 'Error resetting password: $e';
    }
  }

 static Future<bool> verifyResetToken(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/getResetPassword?token=$token'), 
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error verifying reset token: $e');
      return false;
    }
  }

  

  /// this will delete cache
  Future<void> deleteCacheDir() async {
    final cacheDir = await getTemporaryDirectory();

    if (cacheDir.existsSync()) {
      cacheDir.deleteSync(recursive: true);
    }
  }

  /// this will delete app's storage
  Future<void> deleteAppDir() async {
    final appDir = await getApplicationSupportDirectory();

    if (appDir.existsSync()) {
      appDir.deleteSync(recursive: true);
    }
  }
}
