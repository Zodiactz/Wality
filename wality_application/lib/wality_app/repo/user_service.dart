import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:wality_application/wality_app/utils/constant.dart';

class UserService {
  Future<String?> fetchUsername(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/userId/$userId'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data['username'];
    } else {
      print('Failed to fetch username');
      return null;
    }
  }

  Future<String?> fetchUserUID(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/userId/$userId'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data['uid'];
    } else {
      print('Failed to fetch uid');
      return null;
    }
  }

  Future<String?> fetchUserImage(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/userId/$userId'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data['profileImg_link'];
    } else {
      print('Failed to fetch profileImg_link');
      return null;
    }
  }

  Future<String?> fetchImage(String passedImageUrl) async {
    final uri = Uri.parse(
      '$baseUrl/getImage?url=${Uri.encodeComponent(passedImageUrl)}',
    );

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return jsonResponse['profileImg_link'];
      } else {
        print('Failed to load image');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
}
