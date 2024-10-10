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

  Future<List<dynamic>> fetchUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/getAllUsers'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load users');
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
        print(uploadedURL);
        return uploadedURL;
      } else {
        print('Failed to upload image. Status Code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error uploading image: $e');
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
        print("UserId update details ${response.body} from $email to user_id");
        return data['status'] ??
            'UserId updated successfully'; // Adjusted to match 'status' field
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

  Future<String?> updateUserProfile(
      String userId, File? imageFile, String username) async {
    try {
      String? uploadedImageUrl;
      print("this is updateimage: $uploadedImageUrl");

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
        print('userID: $userId, error: ${usernameResponse.body}');
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
        print(data['status']); // e.g., 'User deleted successfully!'
      } else if (response.statusCode == 404) {
        // User not found
        final data = jsonDecode(response.body);
        print(data['status']); // e.g., 'User not found!'
      } else {
        // Other error
        final data = jsonDecode(response.body);
        print('Error: ${data['error']}');
      }
    } catch (e) {
      print('Failed to delete user: $e');
    }
  }

  Future<void> deleteUserByEmail(String email) async {
    final url = Uri.parse('$baseUrl/deleteUserByEmail/$email');

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        // Successfully deleted the user
        final data = jsonDecode(response.body);
        print(data['status']); // e.g., 'User deleted successfully!'
      } else if (response.statusCode == 404) {
        // User not found
        final data = jsonDecode(response.body);
        print(data['status']); // e.g., 'User not found!'
      } else {
        // Other error
        final data = jsonDecode(response.body);
        print('Error: ${data['error']}');
      }
    } catch (e) {
      print('Failed to delete user: $e');
    }
  }

  Future<bool> deleteImageFromFirebase(String imageURL) async {
    // Construct the delete URL with the imageName as a query parameter
    final url = Uri.parse('$baseUrl/deleteOldImage?imageURL=$imageURL');

    // Make a DELETE request to the server
    final response = await http.delete(url);

    // Check the status code to determine if the request was successful
    if (response.statusCode == 200) {
      print("Image deleted successfully.");
      return true;
    } else {
      print("Failed to delete image: ${response.statusCode}, ${response.body}");
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
      print("Error extracting image name: $e");
      return null;
    }
  }
}
