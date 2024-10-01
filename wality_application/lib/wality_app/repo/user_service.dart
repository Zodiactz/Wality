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

  Future<String?> updateImage(String passedImageUrl, String imagePath) async {
    final uri = Uri.parse(
      '$baseUrl/getImage?url=${Uri.encodeComponent(passedImageUrl)}',
    );

    try {
      final response = await http.post(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return jsonResponse['profileImg_link'];
      } else {
        print('Failed to update image');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<String?> updateUsername(String userId, String username) async {
    final uri = Uri.parse(
        '$baseUrl/updateUsername/$userId'); // Ensure this matches your backend endpoint

    try {
      final response = await http.post(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'username': username}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['status'] ??
            'Username updated successfully'; // Adjusted to match 'status' field
      } else if (response.statusCode == 404) {
        return 'User not found!'; // Added handling for 404 case
      } else {
        print(
            'Failed to update username: ${response.statusCode} - ${response.reasonPhrase}');
        print('Response body: ${response.body}');
        return jsonDecode(response.body)['error'] ??
            'Unknown error occurred'; // Extract the error message if available
      }
    } catch (e) {
      print('Error updating username: $e');
      return 'Error updating username: $e';
    }
  }

  Future<void> updateUserFillingTime(String userId) async {
    final uri = Uri.parse('$baseUrl/updateUserFillingTime/$userId');
    final headers = {'Content-Type': 'application/json'};
    final body =
        jsonEncode({'startFillingTime': DateTime.now().toIso8601String()});

    try {
      await http.post(uri, headers: headers, body: body);
    } catch (e) {
      print('Error during HTTP request: $e');
    }
  }

  Future<int?> fetchUserEventBot(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/userId/$userId'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['eventBot'];
      }
    } catch (e) {
      print('Error fetching eventBot: $e');
    }
    return null;
  }

  Future<DateTime?> fetchUserStartTime(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/userId/$userId'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return DateTime.parse(data['startFillingTime']);
      }
    } catch (e) {
      print('Error fetching startFillingTime: $e');
    }
    return null;
  }

  Future<int?> fetchUserFillingLimit(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/userId/$userId'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['fillingLimit'];
      }
    } catch (e) {
      print('Error fetching fillingLimit: $e');
    }
    return null;
  }

  Future<int?> fetchWaterAmount(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/userId/$userId'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['currentMl'];
      }
    } catch (e) {
      print('Error fetching currentMl: $e');
    }
    return null;
  }

  Future<int?> fetchBottleAmount(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/userId/$userId'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['botLiv'];
      }
    } catch (e) {
      print('Error fetching botLiv: $e');
    }
    return null;
  }

  Future<int?> fetchTotalWater(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/userId/$userId'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['totalMl'];
      }
    } catch (e) {
      print('Error fetching totalMl: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> fetchUserData(String userId) async {
    final uri = Uri.parse('$baseUrl/userId/$userId');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        // Parse the JSON response into a Map
        final Map<String, dynamic> userData = jsonDecode(response.body);
        return userData;
      } else {
        print('Failed to fetch user data: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }

  Future<String?> updateUserId(String userId, String user_id) async {
    final uri = Uri.parse(
        '$baseUrl/updateUserId/$userId'); // Ensure this matches your backend endpoint

    try {
      final response = await http.post(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'user_id': user_id}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['status'] ??
            'Username updated successfully'; // Adjusted to match 'status' field
      } else if (response.statusCode == 404) {
        return 'User not found!'; // Added handling for 404 case
      } else {
        print(
            'Failed to update username: ${response.statusCode} - ${response.reasonPhrase}');
        print('Response body: ${response.body}');
        return jsonDecode(response.body)['error'] ??
            'Unknown error occurred'; // Extract the error message if available
      }
    } catch (e) {
      print('Error updating username: $e');
      return 'Error updating username: $e';
    }
  }
}
