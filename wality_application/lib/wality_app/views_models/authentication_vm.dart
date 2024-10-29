import 'package:flutter/material.dart';

class AuthenticationViewModel extends ChangeNotifier {
  String? usernameError;
  String? emailError;
  String? passwordError;
  String? confirmEmailError;
  String? confirmPassErrs;
  String? allErrorSignIn;
  String? allErrorSignUp;
  String? allErrorChangePass;
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

  void setUsernameError(String? error) {
    usernameError = error;

    notifyListeners();
    Future.delayed(const Duration(seconds: 3), () {
      usernameError = null;
      notifyListeners();
    });
  }

  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters long';
    }
    if (value.length > 30) {
      return 'Username must be less than 30 characters';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    return null;
  }

  String? validateEmail(String? value) {
    return (value == null || value.isEmpty)
        ? 'Email is required'
        : (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                .hasMatch(value))
            ? 'Enter a valid email'
            : null;
  }

  void setEmailError(String? error) {
    emailError = error;
    notifyListeners();
    Future.delayed(const Duration(seconds: 3), () {
      emailError = null;
      notifyListeners();
    });
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

  void setPasswordError(String? error) {
    passwordError = error;
    notifyListeners();
    Future.delayed(const Duration(seconds: 3), () {
      passwordError = null;
      notifyListeners();
    });
  }

  void setConfirmPasswordError(String? error) {
    confirmPassErrs = error;
    notifyListeners();
    Future.delayed(const Duration(seconds: 3), () {
      confirmPassErrs = null;
      notifyListeners();
    });
  }

  String? validatePassword(String? value) {
    return (value == null || value.isEmpty)
        ? 'Password is required'
        : (!RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$')
                .hasMatch(value))
            ? 'Password must be at least 8 characters long and contain at least 1 uppercase letter, 1 lowercase letter, 1 digit and 1 special character'
            : null;
  }

  String? validateConfirmPass(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Confirm password is required';
    }

    if (confirmPassword != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  void validateAllSignUp(String usernameVal, String emailVal,
      String passwordVal, String confirmPassEr) async {
    usernameError = validateUsername(usernameVal);
    emailError = validateEmail(emailVal);
    passwordError = validatePassword(passwordVal);
    confirmPassErrs = validateConfirmPass(passwordVal, confirmPassEr);

    if (usernameVal.isEmpty ||
        emailVal.isEmpty ||
        passwordVal.isEmpty ||
        confirmPassEr.isEmpty) {
      allErrorSignUp = 'Please enter all fields';
    } else if (passwordVal != confirmPassEr) {
      allErrorSignUp = "Passwords aren't match";
    } else {
      allErrorSignUp = null;
    }

    _showValidationMessage = usernameError != null ||
        emailError != null ||
        passwordError != null ||
        confirmPassErrs != null ||
        allErrorSignUp != null;

    notifyListeners();
  }

  void setAllSignUpError(String? error) {
    allErrorSignUp = error;
    notifyListeners();
    Future.delayed(const Duration(seconds: 3), () {
      allErrorSignUp = null;
      notifyListeners();
    });
  }

  void validateAllSignIn(String emailVal, String passwordVal) {
    emailError = validateEmail(emailVal);
    passwordError = validatePassword(passwordVal);

    if (emailVal.isEmpty || passwordVal.isEmpty) {
      // Changed condition to check both
      allErrorSignIn = 'Please enter all fields';
    } else {
      allErrorSignIn = null;
    }

    _showValidationMessage =
        emailError != null || passwordError != null || allErrorSignIn != null;

    notifyListeners();
  }

  void setAllSignInError(String? error) {
    allErrorSignIn = error;
    notifyListeners();
    Future.delayed(const Duration(seconds: 3), () {
      allErrorSignIn = null;
      _showValidationMessage = false;
      notifyListeners();
    });
  }

  Future<bool> validateAllForgetPassword(String emailVal) async {
    emailError = validateEmail(emailVal);

    if (emailVal.isEmpty) {
      allErrorSignIn = 'Email and Confirm Email is required';
    } else {
      allErrorSignIn = null;
    }

    _showValidationMessage = emailError != null || allErrorSignIn != null;

    notifyListeners();

    return !_showValidationMessage;
  }

  Future<bool> validateChangePassword(
      String passwordVal, String confirmPassEr) async {
    passwordError = validatePassword(passwordVal);
    confirmPassErrs = validateConfirmPass(passwordVal, confirmPassEr);

    if (passwordVal.isEmpty) {
      allErrorChangePass = 'Please enter all fields';
    } else if (passwordVal != confirmPassEr) {
      allErrorChangePass = "Passwords aren't match";
    } else {
      allErrorChangePass = null;
    }

    _showValidationMessage = passwordError != null ||
        confirmPassErrs != null ||
        allErrorChangePass != null;

    notifyListeners();

    return !_showValidationMessage;
  }

  void clearErrors() {
    usernameError = null;
    emailError = null;
    passwordError = null;
    confirmEmailError = null;
    confirmPassErrs = null;
    allErrorSignIn = null;
    allErrorSignUp = null;
    allErrorChangePass = null;
    _showValidationMessage = false;
    notifyListeners();
  }
}
