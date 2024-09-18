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
}
