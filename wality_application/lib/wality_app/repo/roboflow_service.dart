import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wality_application/wality_app/utils/constant.dart';

class RoboflowService {
  final String apiKey = "G0Aiyz9rnxZVeRTWMV2p"; // Your Roboflow API key
  final String endpoint = roboflowUrl; // Your Roboflow endpoint

  // Function to run Roboflow inference
  Future<Map<String, dynamic>> runInference(String imageUrl) async {
    try {
      // Prepare the request body
      final data = {
        "api_key": apiKey,
        "inputs": {
          "image": {
            "type": "url",
            "value": imageUrl,
          },
        },
      };

      // Send the request to Roboflow
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode(data),
      );
      print(data);
      // Check if the request was successful
      if (response.statusCode == 200) {
        final Map<String, dynamic> result = json.decode(response.body);

        // Check if the response contains predictions
        if (result["outputs"] != null && result["outputs"].isNotEmpty) {
          return {
            "message": "Predictions found",
            "predictions": result["outputs"],
          };
        } else {
          return {
            "message": "No predictions found for the image. Please try a different image.",
          };
        }
      } else {
        // Handle unsuccessful responses
        return {
          "error": "Failed to make request to Roboflow. Status code: ${response.statusCode}",
        };
      }
    } catch (e) {
      // Handle any errors
      return {
        "error": "An error occurred: $e",
      };
    }
  }
}
