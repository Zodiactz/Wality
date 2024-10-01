import 'dart:io';
import 'package:mime/mime.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; 
import 'package:path/path.dart';
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

  Future<String?> uploadImage(File imageFile) async {
    final uri = Uri.parse('$baseUrl/uploadImage');
    
    // Get the file name and its MIME type
    final mimeType = lookupMimeType(imageFile.path) ?? 'application/octet-stream';
    final fileName = basename(imageFile.path);
    
    try {
      // Create a multipart request
      final request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath(
          'image', 
          imageFile.path,
          contentType: MediaType.parse(mimeType),
        ));
          print('Starting upload for: ${imageFile.path}');


      // Send the request
      final streamedResponse = await request.send();

      // Parse the response
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['imageURL']; // Returns the URL of the uploaded image
      } else {
        print('Failed to upload image: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error uploading image: $e');
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

  Future<String?> updateUserProfile(String userId, String username, String profileImageUrl) async {
    try {
      // Create the body with the new username and profile image link
      Map<String, dynamic> body = {
        'username': username,
        'profileImg_link': profileImageUrl,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/userId/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return 'Profile updated successfully';
      } else {
        print('Failed to update profile. Status code: ${response.statusCode}');
        return 'Failed to update profile';
      }
    } catch (e) {
      print('Error updating profile: $e');
      return 'Error updating profile';
    }
  }

}
