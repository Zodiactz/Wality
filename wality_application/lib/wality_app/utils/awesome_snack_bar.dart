import 'package:flutter/material.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

void showAwesomeSnackBar(
    BuildContext context, String title, String message, ContentType type) {
  final snackBar = SnackBar(
    elevation: 0,
    backgroundColor: Colors.transparent,
    behavior: SnackBarBehavior.floating,
    content: AwesomeSnackbarContent(
      title: title,
      message: message,
      contentType: type,
    ),
    duration: const Duration(seconds: 2), // Set the duration to 3 seconds
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
