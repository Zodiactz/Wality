import 'package:flutter/material.dart';

class ChangeInfoViewModel extends ChangeNotifier {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final FocusNode usernameFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode confirmPasswordFocusNode = FocusNode();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? usernameError;
  String? passwordError;
  String? confirmPasswordError;
  String? allError;
  bool _isScrollable = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _showValidationMessage = false;

  bool get isScrollable => _isScrollable;
  bool get passwordVisible => _passwordVisible;
  bool get confirmPasswordVisible => _confirmPasswordVisible;
  bool get showValidationMessage => _showValidationMessage;

  ChangeInfoViewModel() {
    usernameFocusNode.addListener(_onFocusChange);
    passwordFocusNode.addListener(_onFocusChange);
    confirmPasswordFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    _isScrollable = usernameFocusNode.hasFocus || passwordFocusNode.hasFocus || confirmPasswordFocusNode.hasFocus;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _passwordVisible = !_passwordVisible;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _confirmPasswordVisible = !_confirmPasswordVisible;
    notifyListeners();
  }

  String? validateUsername(String? value) {
    return (value == null || value.isEmpty) ? 'Username is required.' : null;
  }

  String? validatePassword(String? value) {
    return (value == null || value.isEmpty)
        ? 'Password is required.'
        : (!RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$')
                .hasMatch(value))
            ? 'Password must be at least 8 characters long and contain at least 1 uppercase letter, 1 lowercase letter, 1 digit and 1 special character'
            : null;
  }

  String? validateConfirmPassword(String? value) {
    return (value == null || value.isEmpty)
        ? 'Confirm Password is required.'
        : (value != passwordController.text)
            ? 'Password does not match'
            : null;
  }

  void validationAll() {
    usernameError = validateUsername(usernameController.text);
    passwordError = validatePassword(passwordController.text);
    confirmPasswordError = validateConfirmPassword(confirmPasswordController.text);

    _showValidationMessage =
        usernameError != null || passwordError != null || confirmPasswordError != null || allError != null;

    notifyListeners();
  }

  void changeInfo(BuildContext context) {
    final currentState = formKey.currentState;
    if (currentState != null && currentState.validate()) {
      Navigator.pushNamed(context, '/profilepage');
    } else {
      validationAll();
      if (allError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(allError!)),
        );
      } else if (usernameError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(usernameError!)),
        );
      } else if (passwordError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(passwordError!)),
        );
      } else if (confirmPasswordError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(confirmPasswordError!)),
        );
      }
    }
  }
}
