// ignore_for_file: non_constant_identifier_names, depend_on_referenced_packages

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'package:wality_application/wality_app/utils/constant.dart';
import 'package:intl/intl.dart';

class UserService {
  Future<String?> fetchUsername(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/userId/$userId'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data['username'];
    } else {
      return null;
    }
  }

  Future<String?> fetchEmail(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/userId/$userId'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data['email'];
    } else {
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
      return null;
    }
  }

  Future<String?> fetchRealName(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/userId/$userId'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data['realName'];
    } else {
      return null;
    }
  }

  Future<String?> fetchSID(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/userId/$userId'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data['sID'];
    } else {
      return null;
    }
  }

  Future<List<String>?> fetchCouponCheck(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/userId/$userId'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      List<String> couponCheck = List<String>.from(data['couponCheck']);
      return couponCheck;
    } else {
      return null;
    }
  }

  Future<String?> updateUserUsedWcoin(String userId, int wCoin) async {
    final uri = Uri.parse(
        '$baseUrl/updateUserUsedWcoin/$userId'); // Ensure this matches your backend endpoint

    try {
      final response = await http.post(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'usedWcoin': wCoin}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        return data['status'] ??
            'Used usedWcoin updated successfully'; // Adjusted to match 'status' field
      } else if (response.statusCode == 404) {
        return 'User not found!'; // Added handling for 404 case
      } else {
        return jsonDecode(response.body)['error'] ??
            'Unknown error occurred'; // Extract the error message if available
      }
    } catch (e) {
      return 'Error updating usedWcoin: $e';
    }
  }

// Fetch function
  Future<List<Map<String, dynamic>>?> fetchCouponHistory(String userId) async {
  final response = await http.get(Uri.parse('$baseUrl/userId/$userId'));
  
  if (response.statusCode == 200) {
    final Map data = jsonDecode(response.body);
    print('Raw fetched data: $data'); // Debug raw data
    
    if (data['couponHistory'] is List) {
      List<Map<String, dynamic>> couponHistory = 
          List<Map<String, dynamic>>.from(data['couponHistory']);
      
      for (var coupon in couponHistory) {
        print('Processing coupon before date handling: $coupon'); // Debug each coupon
        
        // Handle authorizedBy field
        coupon['authorizedBy'] = coupon['authorizedBy'] ?? 'Unknown';
        
        if (coupon['used_at'] != null) {
          if (coupon['used_at'] is String) {
            try {
              DateTime utcDate = DateTime.parse(coupon['used_at']);
              DateTime localDate = utcDate.toLocal();
              coupon['used_at'] = localDate.toString();
              print('Processed date for coupon: ${coupon['used_at']}'); // Debug processed date
            } catch (e) {
              print('Error parsing direct date string: $e');
              coupon['used_at'] = null;
            }
          } else if (coupon['used_at'] is Map && 
                    coupon['used_at']['\$date'] != null) {
            try {
              String dateString = coupon['used_at']['\$date'];
              DateTime utcDate = DateTime.parse(dateString);
              DateTime localDate = utcDate.toLocal();
              coupon['used_at'] = localDate.toString();
              print('Processed MongoDB date for coupon: ${coupon['used_at']}'); // Debug processed date
            } catch (e) {
              print('Error parsing MongoDB date: $e');
              coupon['used_at'] = null;
            }
          }
        }
      }
      
      print('Final processed coupon history: $couponHistory'); // Debug final data
      return couponHistory;
    }
    return [];
  }
  return null;
}

// Card widget
  Future<List<dynamic>> fetchUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/getAllUsers'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load users');
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

  Future<String?> fetchUserImage(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/userId/$userId'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data['profileImg_link'];
    } else {
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
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> updateUserFillingTime(String userId) async {
    final uri = Uri.parse('$baseUrl/updateUserFillingTime/$userId');
    final headers = {'Content-Type': 'application/json'};

    // Get the current local time
    final now = DateTime.now();

    // Format to include milliseconds and 'Z' at the end
    final formattedTime =
        '${now.toIso8601String().split('.').first}.${now.millisecond.toString().padLeft(3, '0')}Z';

    final body = jsonEncode({'startFillingTime': formattedTime});

    try {
      await http.post(uri, headers: headers, body: body);
    } catch (e) {
      throw Exception('Failed to load FillingTime');
    }
  }

  Future<bool?> fetchUserAdmin(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/userId/$userId'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['isAdmin'];
      }
    } catch (e) {
      throw Exception('Failed to load UserAdmin');
    }
    return null;
  }

  Future<int?> fetchUserEventBot(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/userId/$userId'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['eventBot'];
      }
    } catch (e) {
      throw Exception('Failed to load EventBot');
    }
    return null;
  }

  Future<String?> updateUserEventBot(String userId, int eventBot) async {
    final uri = Uri.parse(
        '$baseUrl/updateUserEventBot/$userId'); // Ensure this matches your backend endpoint

    try {
      final response = await http.post(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'eventBot': eventBot}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        return data['status'] ??
            'eventBot updated successfully'; // Adjusted to match 'status' field
      } else if (response.statusCode == 404) {
        return 'User not found!'; // Added handling for 404 case
      } else {
        return jsonDecode(response.body)['error'] ??
            'Unknown error occurred'; // Extract the error message if available
      }
    } catch (e) {
      return 'Error updating eventBot: $e';
    }
  }

  Future<int?> fetchUserDayBot(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/userId/$userId'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['dayBot'];
      }
    } catch (e) {
      throw Exception('Failed to load DayBot');
    }
    return null;
  }

  Future<int?> fetchUserMonthBot(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/userId/$userId'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['monthBot'];
      }
    } catch (e) {
      throw Exception('Failed to load MonthBot');
    }
    return null;
  }

  Future<int?> fetchUserYearBot(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/userId/$userId'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['yearBot'];
      }
    } catch (e) {
      throw Exception('Failed to load YearBot');
    }
    return null;
  }

  Future<int?> fetchUserUsedWcoin(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/userId/$userId'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['usedWcoin'];
      }
    } catch (e) {
      throw Exception('Failed to load used wCoin');
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
      return null;
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
      throw Exception('Failed to load FillingLimit');
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
      throw Exception('Failed to load WaterAmount');
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
      throw Exception('Failed to load BottleAmount');
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
      throw Exception('Failed to load TotalWater');
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
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Function to upload image and store the returned URL
  Future<String?> uploadImage(File imageFile) async {
    try {
      // Create the request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/uploadImage'),
      );

      // Add the image file to the request
      var mimeTypeData = lookupMimeType(imageFile.path)?.split('/');
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          contentType: MediaType(mimeTypeData![0], mimeTypeData[1]),
        ),
      );

      // Send the request
      var response = await request.send();

      // Handle the response
      if (response.statusCode == 200) {
        // Parse the response body to get the uploaded image URL
        var responseData = await http.Response.fromStream(response);
        var jsonResponse = jsonDecode(responseData.body);

        // Extract the uploaded image URL
        String uploadedURL = jsonResponse['imageURL'];

        // Save or return the uploaded URL

        return uploadedURL;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<String?> updateUserIdByEmal(String email, String userId) async {
    final uri = Uri.parse(
        '$baseUrl/updateUserId/$email'); // Ensure this matches your backend endpoint

    try {
      final response = await http.post(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'user_id': userId}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        return data['status'] ??
            'UserId updated successfully'; // Adjusted to match 'status' field
      } else if (response.statusCode == 404) {
        return 'User not found!'; // Added handling for 404 case
      } else {
        return jsonDecode(response.body)['error'] ??
            'Unknown error occurred'; // Extract the error message if available
      }
    } catch (e) {
      return 'Error updating username: $e';
    }
  }

  Future<String?> updateUserProfile(
      String userId, File? imageFile, String username) async {
    try {
      String? uploadedImageUrl;

      // Only upload the image if an imageFile is provided
      if (imageFile != null) {
        uploadedImageUrl = await uploadImage(imageFile);
        if (uploadedImageUrl == null) {
          return 'Failed to upload image.';
        }
      }

      // After successful image upload (if provided), attempt to update the profile
      final imageUpdateUri = Uri.parse('$baseUrl/updateImage/$userId');
      final usernameUpdateUri = Uri.parse('$baseUrl/updateUsername/$userId');
      final oldImage = await fetchUserImage(userId) ?? "";

      // Conditionally update the image URL if one was uploaded
      if (uploadedImageUrl != null) {
        deleteImageFromFirebase(oldImage);
        final imageResponse = await http.post(
          imageUpdateUri,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({'profileImg_link': uploadedImageUrl}),
        );

        if (imageResponse.statusCode != 200) {
          return 'Failed to update image.';
        }
      }

      // Update the username
      final usernameResponse = await http.post(
        usernameUpdateUri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'username': username}),
      );

      if (usernameResponse.statusCode == 200) {
        return 'User profile updated successfully';
      } else if (usernameResponse.statusCode == 404) {
        return 'User not found when updating username!';
      } else {
        return jsonDecode(usernameResponse.body)['error'] ??
            'Unknown error occurred when updating username';
      }
    } catch (e) {
      return 'Error updating user profile: $e';
    }
  }

  Future<void> deleteUser(String userId) async {
    final url = Uri.parse('$baseUrl/deleteUser/$userId');

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        // Successfully deleted the user
        final data = jsonDecode(response.body);
        // e.g., 'User deleted successfully!'
        throw Exception('$data');
      } else if (response.statusCode == 404) {
        // User not found
        final data = jsonDecode(response.body);
        // e.g., 'User not found!'
        throw Exception('$data');
      } else {
        // Other error
        final data = jsonDecode(response.body);
        throw Exception('$data');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  Future<void> deleteUserByEmail(String email) async {
    final url = Uri.parse('$baseUrl/deleteUserByEmail/$email');

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        // Successfully deleted the user
        final data = jsonDecode(response.body);
        // e.g., 'User deleted successfully!'
        throw Exception('$data');
      } else if (response.statusCode == 404) {
        // User not found
        final data = jsonDecode(response.body);
        // e.g., 'User not found!'
        throw Exception('$data');
      } else {
        // Other error
        final data = jsonDecode(response.body);
        throw Exception('$data');
      }
    } catch (e) {
      throw Exception('Failed to delete user email');
    }
  }

  Future<bool> deleteImageFromFirebase(String imageURL) async {
    // Construct the delete URL with the imageName as a query parameter
    final url = Uri.parse('$baseUrl/deleteOldImage?imageURL=$imageURL');

    // Make a DELETE request to the server
    final response = await http.delete(url);

    // Check the status code to determine if the request was successful
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  String? extractImageNameFromUrl(String imageUrl) {
    try {
      // Parse the URL
      Uri uri = Uri.parse(imageUrl);

      // Extract the path segment after "/o/"
      List<String> segments = uri.path.split('/o/');
      if (segments.length < 2) {
        return null; // Invalid URL format
      }

      // The second part contains the image name
      String imageName = segments[1];

      // Optionally decode the URL-encoded image name
      return Uri.decodeComponent(imageName);
    } catch (e) {
      return null;
    }
  }

  ImageProvider getProfileImage(String? profileImgLink) {
    if (profileImgLink != null && profileImgLink.isNotEmpty) {
      return NetworkImage(profileImgLink);
    } else {
      return const AssetImage('assets/images/cat.png');
    }
  }
}
