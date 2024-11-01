import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wality_application/wality_app/repo/auth_service.dart';
import 'package:realm/realm.dart';
import 'package:wality_application/wality_app/utils/navigator_utils.dart';
import 'package:wality_application/wality_app/utils/text_form_field_authen.dart';
import 'package:wality_application/wality_app/views/setting_page.dart';
import 'package:wality_application/wality_app/views_models/authentication_vm.dart';

class ResetPasswordPage extends StatefulWidget {
  final String token;
  final String tokenId;
  const ResetPasswordPage(
      {super.key, required this.token, required this.tokenId});

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode confirmPassFocusNode = FocusNode();
  bool _isLoading = false;
  final App app = App(AppConfiguration('wality-1-djgtexn'));
  final authService = AuthService();
  final settingService = SettingPage();

  void _showDialogWithLogOut(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                LogOutToOutsite(context);
                // Resume scanning after dialog is dismissed
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _resetPassword() async {
    EmailPasswordAuthProvider authProvider = EmailPasswordAuthProvider(app);
    if (passwordController.text != confirmPassController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Add the logic to complete password reset using widget.token and widget.tokenId
      await authProvider.completeResetPassword(
          passwordController.text, widget.token, widget.tokenId);

      _showDialogWithLogOut('Change Password Successfully',
          'Click OK to bring you back to the login page');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(body:
          Consumer<AuthenticationViewModel>(builder: (context, authvm, child) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0083AB), Color(0xFF003545)],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 20.0),
                    child: Text(
                      'Reset Password Page',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30, left: 15, right: 15),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'New Password',
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'RobotoCondensed',
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: 360,
                            height: 50,
                            child: TextFormFieldAuthen(
                              controller: passwordController,
                              hintText: "Password",
                              obscureText: !authvm.passwordVisible1,
                              focusNode: passwordFocusNode,
                              suffixIcon: IconButton(
                                icon: Icon(authvm.passwordVisible1
                                    ? Icons.visibility
                                    : Icons.visibility_off),
                                color: Colors.grey,
                                onPressed: () {
                                  authvm.togglePasswordVisibility1();
                                },
                              ), 
                            ),
                          ),
                          const SizedBox(height: 40),
                          const Text(
                            'Please enter the same password to confirm the change',
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'RobotoCondensed',
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: 360,
                            height: 50,
                            child: TextFormFieldAuthen(
                              controller: confirmPassController,
                              hintText: "Confirm password",
                              obscureText: !authvm.passwordVisible2,
                              focusNode: confirmPassFocusNode,
                              suffixIcon: IconButton(
                                icon: Icon(authvm.passwordVisible2
                                    ? Icons.visibility
                                    : Icons.visibility_off),
                                color: Colors.grey,
                                onPressed: () {
                                  authvm.togglePasswordVisibility2();
                                },
                              ), 
                            ),
                          ),
                          const SizedBox(height: 40),
                          Padding(
                            padding: const EdgeInsets.only(left: 30),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _resetPassword,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF342056),
                                fixedSize: const Size(300, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width:
                                          24, // Set a fixed width for the spinner
                                      height:
                                          24, // Set a fixed height for the spinner
                                      child: CircularProgressIndicator(
                                        color: Colors
                                            .white, // Set the spinner color to match the button text color
                                        strokeWidth: 2, // Set the stroke width
                                      ),
                                    )
                                  : const Text(
                                      'Change',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'RobotoCondensed',
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      })),
    );
  }
}
