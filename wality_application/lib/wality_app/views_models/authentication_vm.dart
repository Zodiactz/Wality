import 'package:flutter/material.dart';

class AuthenticationViewModel extends ChangeNotifier {
  String? usernameError;
  String? emailError;
  String? passwordError;
  String? confirmEmailError;
  String? confirmPassErrs;
  String? allError;
  final bool _isScrollable = false;
  bool _passwordVisible1 = false;
  bool _passwordVisible2 = false;
  bool _showValidationMessage = false;

  bool get isScrollable => _isScrollable;
  bool get passwordVisible1 => _passwordVisible1;
  bool get passwordVisible2 => _passwordVisible2;
  bool get showValidationMessage => _showValidationMessage;

  void togglePasswordVisibility1() {
    _passwordVisible1 = !_passwordVisible1;
    notifyListeners();
  }

  void togglePasswordVisibility2() {
    _passwordVisible2 = !_passwordVisible2;
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

  String? validateConfirmPass(String? value, String? value2) {
    if (value2 == null || value2.isEmpty) {
      return 'Confirm passoword is required';
    } else if (value2 != value) {
      return 'Passwords does not match';
    }
    return null;
  }

  Future<bool> validateAllSignUp(String usernameVal, String emailVal,
      String passwordVal, String confirmPassEr) async {
    usernameError = validateUsername(usernameVal);
    emailError = validateEmail(emailVal);
    passwordError = validatePassword(passwordVal);
    confirmPassErrs = validateConfirmPass(passwordVal, confirmPassEr);

    if (usernameVal.isEmpty || emailVal.isEmpty || passwordVal.isEmpty) {
      allError = 'Please enter all fields';
    } else if (passwordVal != confirmPassEr) {
      allError = "Passwords aren't match";
    } else {
      allError = null;
    }

    _showValidationMessage = usernameError != null ||
        emailError != null ||
        passwordError != null ||
        confirmPassErrs != null ||
        allError != null;

    notifyListeners();

    return !_showValidationMessage;
  }

  Future<bool> validateAllSignIn(String emailVal, String passwordVal) async {
    emailError = validateEmail(emailVal);
    passwordError = validatePassword(passwordVal);

    if (emailVal.isEmpty && passwordVal.isEmpty) {
      allError = 'Please enter all fields';
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
