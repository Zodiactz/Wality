import 'package:flutter/material.dart';

class AuthenticationViewModel extends ChangeNotifier {
  String? usernameError;
  String? emailError;
  String? passwordError;
  String? confirmEmailError;
  String? allError;
  final bool _isScrollable = false;
  bool _passwordVisible = false;
  bool _showValidationMessage = false;

  bool get isScrollable => _isScrollable;
  bool get passwordVisible => _passwordVisible;
  bool get showValidationMessage => _showValidationMessage;

  void togglePasswordVisibility() {
    _passwordVisible = !_passwordVisible;
    notifyListeners();
  }

  String? validateUsername(String? value) {
    return (value == null || value.isEmpty) ? 'Username is required' : null;
  }

  String? validateEmail(String? value) {
    return (value == null || value.isEmpty)
        ? 'Email is required'
        : (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                .hasMatch(value))
            ? 'Enter a valid email'
            : null;
  }

  String? validateConfirmEmail(String? email, String? confirmEmail) {
    if (confirmEmail == null || confirmEmail.isEmpty) {
      return 'Confirm Email is required';
    }
    if (email != confirmEmail) {
      return 'Email does not match';
    }
    return null;
  }

  String? validatePassword(String? value) {
    return (value == null || value.isEmpty)
        ? 'Password is required'
        : (!RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$')
                .hasMatch(value))
            ? 'Password must be at least 8 characters long and contain at least 1 uppercase letter, 1 lowercase letter, 1 digit and 1 special character'
            : null;
  }

  Future<bool> validateAllSignUp(
      String usernameVal, String emailVal, String passwordVal) async {
    usernameError = validateUsername(usernameVal);
    emailError = validateEmail(emailVal);
    passwordError = validatePassword(passwordVal);

    if (usernameVal.isEmpty && emailVal.isEmpty && passwordVal.isEmpty) {
      allError = 'Username, Email, and Password are required';
    } else if (emailVal.isEmpty && passwordVal.isEmpty) {
      allError = 'Email and Password are required';
    } else {
      allError = null;
    }

    _showValidationMessage = usernameError != null ||
        emailError != null ||
        passwordError != null ||
        allError != null;

    notifyListeners();

    return !_showValidationMessage;
  }

  Future<bool> validateAllSignIn(String emailVal, String passwordVal) async {
    emailError = validateEmail(emailVal);
    passwordError = validatePassword(passwordVal);

    if (emailVal.isEmpty && passwordVal.isEmpty) {
      allError = 'Email and Password are required';
    } else {
      allError = null;
    }

    _showValidationMessage =
        emailError != null || passwordError != null || allError != null;

    notifyListeners();

    return !_showValidationMessage;
  }

  Future<bool> validateAllForgetPassword(
      String emailVal, String confirmEmailVal) async {
    emailError = validateEmail(emailVal);
    confirmEmailError = validateConfirmEmail(emailVal, confirmEmailVal);

    if (emailVal.isEmpty && confirmEmailVal.isEmpty) {
      allError = 'Email and Confirm Email is required';
    } else if (confirmEmailError != null) {
      allError = confirmEmailError;
    } else {
      allError = null;
    }

    _showValidationMessage = emailError != null || allError != null;

    notifyListeners();

    return !_showValidationMessage;
  }
}
