import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:realm/realm.dart';
import 'package:wality_application/wality_app/utils/navigator_utils.dart';
import 'package:wality_application/wality_app/views/waterCheck/New_waterChecking.dart';

final App app = App(AppConfiguration('wality-1-djgtexn'));
final userId = app.currentUser?.id;

class QrScannerPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  Future<int?>? currentWater;
  Future<int?>? currentBottle;
  Future<int?>? totalWater;
  Future<int?>? sentCurrentWater;
  Future<int?>? sentCurrentBottle;
  Future<int?>? sentTotalWater;
  String? waterid;

  // Define the method to update user water data
  Future<bool> updateUserWater(
      String userId, int currentMl, int botLiv, int totalMl) async {
    final uri = Uri.parse('http://localhost:8080/updateUserWater/$userId');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'currentMl': currentMl,
      'botLiv': botLiv,
      'totalMl': totalMl,
    });

    try {
      final response = await http.post(uri, headers: headers, body: body);
      if (response.statusCode == 200) {
        return true; // Successfully updated
      } else {
        print('Failed to update user: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  Future<bool> updateWaterStatus(String waterId, String status) async {
    final uri = Uri.parse('http://localhost:8080/updateWaterStatus/$waterId');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'status': status,
    });

    try {
      final response = await http.post(uri, headers: headers, body: body);

      if (response.statusCode == 200) {
        // Successfully updated
        return true;
      } else {
        // Log response body for debugging
        print('Failed to update water status. Response: ${response.body}');
        return false;
      }
    } catch (e) {
      // Handle request error
      print('Error updating water status: $e');
      return false;
    }
  }

  Future<int?> fetchWaterId(String waterId) async {
    final response = await http.get(
      Uri.parse('http://localhost:8080/waterId/$waterId'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data['quantity'];
    } else {
      print('Failed to fetch waterId');
      return null;
    }
  }

  Future<int?> fetchWaterAmount(String userId) async {
    final response = await http.get(
      Uri.parse('http://localhost:8080/userId/$userId'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data['currentMl'];
    } else {
      print('Failed to fetch currentMl');
      return null;
    }
  }

  Future<int?> fetchBottleAmount(String userId) async {
    final response = await http.get(
      Uri.parse('http://localhost:8080/userId/$userId'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data['botLiv'];
    } else {
      print('Failed to fetch botLiv');
      return null;
    }
  }

  Future<int?> fetchTotalWater(String userId) async {
    final response = await http.get(
      Uri.parse('http://localhost:8080/userId/$userId'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data['totalMl'];
    } else {
      print('Failed to fetch totalMl');
      return null;
    }
  }

  void _showDialogWithAutoDismiss(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            // No action buttons to ensure the dialog cannot be dismissed
          ],
        );
      },
    );
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                // Resume scanning after dialog is dismissed
                controller?.resumeCamera();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDialogContinue(String title, String message, int sentCurrentWaterGo,
      int sentCurrentBottleGo, int sentWaterAmountGo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                // Resume scanning after dialog is dismissed
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewWaterChecking(
                      sentCurrentWater: sentCurrentWaterGo,
                      sentCurrentBottle: sentCurrentBottleGo,
                      sentWaterAmount: sentWaterAmountGo,
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    // Initialize current water and bottle
    currentWater = fetchWaterAmount(userId!);
    currentBottle = fetchBottleAmount(userId!);
    totalWater = fetchTotalWater(userId!);
    sentCurrentWater = fetchWaterAmount(userId!);
    sentCurrentBottle = fetchBottleAmount(userId!);
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    } else if (Platform.isIOS) {
      controller?.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.white,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      // Pause scanning while processing
      controller.pauseCamera();

      // Show dialog indicating scanning
      _showDialogWithAutoDismiss(
          'Scanning', 'Please wait while we process the QR code...');

      // Ensure the dialog is shown before proceeding
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // Introduce a delay of 2 seconds
        await Future.delayed(Duration(seconds: 2));

        // Close the dialog after the delay
        Navigator.of(context).pop();

        // Proceed with the rest of the logic
        final waterAmount = await fetchWaterId(scanData.code ?? '');
        if (waterAmount != null) {
          // Fetch and update user water data
          var currentMl = (await currentWater ?? 0) + waterAmount;
          var botLiv = (await currentBottle ?? 0);
          final totalMl = (await totalWater ?? 0) + waterAmount;

          // Adjust the values if necessary
          if (currentMl >= 550) {
            botLiv += currentMl ~/ 550;
            currentMl = currentMl % 550;
          }

          if (await updateUserWater(userId!, currentMl, botLiv, totalMl)) {
            updateWaterStatus(scanData.code ?? '', "active");
            // Pass values to the animation page
            // Await the Future values before navigating
            final sentCurrentWaterGo = await sentCurrentWater;
            final sentCurrentBottleGo = await sentCurrentBottle;
            _showDialogContinue(
                'Success',
                'Your water has been updated! Please wait for a few seconds',
                sentCurrentWaterGo!,
                sentCurrentBottleGo!,
                waterAmount);
          } else {
            _showDialog(
                'Error', 'Failed to update your water. Please try again.');
          }
        } else {
          _showDialog('Unavailable',
              'This QR code is unavailable. Please try another.');
        }
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
