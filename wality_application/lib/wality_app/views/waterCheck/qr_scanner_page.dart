// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:realm/realm.dart';
import 'package:wality_application/wality_app/repo/realm_service.dart';
import 'package:wality_application/wality_app/repo/user_service.dart';
import 'package:wality_application/wality_app/repo/water_service.dart';

import 'package:wality_application/wality_app/utils/navigator_utils.dart';
import 'package:wality_application/wality_app/views/waterCheck/water_checking.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

final App app = App(AppConfiguration('wality-1-djgtexn'));
final WaterService waterService = WaterService();
final UserService userService = UserService();
final RealmService _realmService = RealmService();
String? currentUserId;

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<StatefulWidget> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  Future<int?>? currentWater;
  Future<int?>? currentBottle;
  Future<int?>? totalWater;
  Future<int?>? fillingLimit;
  Future<int?>? sentCurrentWater;
  Future<int?>? sentCurrentBottle;
  Future<int?>? sentTotalWater;
  String? waterid;
  Future<DateTime?>? startHour;
  Future<int?>? eBot;
  Future<int?>? dBot;
  Future<int?>? mBot;
  Future<int?>? yBot;
  Future<int?>? eMl;

  String formatDateToECMA(DateTime date) {
    // Format to "yyyy-MM-ddTHH:mm:ss.SSS"
    return '${DateFormat("yyyy-MM-ddTHH:mm:ss.SSS").format(date)}Z';
  }

  DateTime? removeZFromDateTime(DateTime? dateTime) {
    // If the input DateTime is null, return null
    if (dateTime == null) {
      return null;
    }

    // Convert DateTime to string and remove 'Z'
    String dateTimeString = dateTime.toIso8601String();
    if (dateTimeString.endsWith('Z')) {
      dateTimeString = dateTimeString.substring(0, dateTimeString.length - 1);
    }

    // Parse the string back to DateTime and return
    return DateTime.parse(dateTimeString);
  }

  void _showDialogWithAutoDismiss(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: const <Widget>[
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
              child: const Text('OK'),
              onPressed: () {
                GoBack(context);
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
              child: const Text('OK'),
              onPressed: () {
                GoBack(context);
                // Resume scanning after dialog is dismissed
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WaterChecking(
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
    currentUserId = _realmService.getCurrentUserId();
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() {
    if (currentUserId != null) {
      currentWater = userService.fetchWaterAmount(currentUserId!);
      currentBottle = userService.fetchBottleAmount(currentUserId!);
      totalWater = userService.fetchTotalWater(currentUserId!);
      fillingLimit = userService.fetchUserFillingLimit(currentUserId!);
      startHour = userService.fetchUserStartTime(currentUserId!);
      eBot = userService.fetchUserEventBot(currentUserId!);
      dBot = userService.fetchUserDayBot(currentUserId!);
      mBot = userService.fetchUserMonthBot(currentUserId!);
      yBot = userService.fetchUserYearBot(currentUserId!);
      eMl = userService.fetchUserEventMl(currentUserId!);
    } else {
      throw Exception("User ID is null, cannot fetch data.");
    }
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
        await Future.delayed(const Duration(seconds: 2));

        // Close the dialog after the delay
        GoBack(context);

        // Proceed with the rest of the logic
        final waterAmount =
            await waterService.fetchWaterId(scanData.code ?? '');

        if (waterAmount != null) {
          final startTime = removeZFromDateTime((await startHour));
          final limitTest = (await fillingLimit ?? 0);
          DateTime now = DateTime.now();

          Duration? difference;
          if (startTime != null) {
            difference = now.difference(startTime);
          }

          if ((limitTest + waterAmount <= 2000 &&
                  (difference != null && difference.inHours < 1)) ||
              (difference != null && difference.inHours >= 1) ||
              (limitTest + waterAmount <= 2000 && difference == null)) {
            // If more than an hour has passed, reset fillingLimit
            if (difference != null && difference.inHours >= 1) {
              fillingLimit = Future.value(0);
            }

            // Fetch and update user water data
            var currentMl = (await currentWater ?? 0) + waterAmount;
            var botLiv = (await currentBottle ?? 0);
            final totalMl = (await totalWater ?? 0) + waterAmount;
            final limit = (await fillingLimit ?? 0) + waterAmount;
            var eventBot = (await eBot ?? 0);
            var eventMl = (await eMl ?? 0) + waterAmount;
            var dayBot = (await dBot ?? 0);
            var monthBot = (await mBot ?? 0);
            var yearBot = (await yBot ?? 0);

            // Adjust the values if necessary
            if (currentMl >= 550) {
              eventBot += currentMl ~/ 550;
              dayBot += currentMl ~/ 550;
              monthBot += currentMl ~/ 550;
              yearBot += currentMl ~/ 550;
              botLiv += currentMl ~/ 550;
              currentMl = currentMl % 550;
              eventMl = eventMl % 550;
            }

            // Update user water details
            if (await waterService.updateUserWater(
                currentUserId!,
                currentMl,
                eventMl,
                botLiv,
                totalMl,
                limit,
                eventBot,
                dayBot,
                monthBot,
                yearBot)) {
              waterService.updateWaterStatus(scanData.code ?? '', "active");

              // Update filling time if the time difference is more than 1 hour or is null
              if (difference == null || (difference.inHours >= 1)) {
                await userService.updateUserFillingTime(currentUserId!);
              }
              //test commit

              // Continue after successful update
              final sentCurrentWaterGo = await sentCurrentWater ?? 0;
              final sentCurrentBottleGo = await sentCurrentBottle ?? 0;

              _showDialogContinue(
                  'Success',
                  'Your water has been updated! Please wait for a few seconds',
                  sentCurrentWaterGo,
                  sentCurrentBottleGo,
                  waterAmount);
            } else {
              _showDialog(
                  'Error', 'Failed to update your water. Please try again.');
            }
          } else {
            _showDialog('Exceeded limit',
                'Your water filling has exceeded the limit. Please wait');
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
