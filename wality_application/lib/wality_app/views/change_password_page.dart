import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wality_application/wality_app/repo/realm_service.dart';
import 'package:wality_application/wality_app/repo/user_service.dart';
import 'package:wality_application/wality_app/utils/LoadingOverlay.dart';
import 'package:wality_application/wality_app/utils/awesome_snack_bar.dart';
import 'package:wality_application/wality_app/utils/navigator_utils.dart';
import 'package:wality_application/wality_app/utils/text_form_field_authen.dart';
import 'package:wality_application/wality_app/views_models/authentication_vm.dart';
import 'package:realm/realm.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode confirmPassFocusNode = FocusNode();
  final RealmService _realmService = RealmService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final FocusNode usernameFocusNode = FocusNode();
  final AuthenticationViewModel authvm = AuthenticationViewModel();
  final App app = App(AppConfiguration('wality-1-djgtexn'));
  Future<String?>? usernameFuture;
  final UserService _userService = UserService();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final userId = _realmService.getCurrentUserId();
    usernameFuture = _userService.fetchUsername(userId!);
  }

  @override
  @override
  void dispose() {
    // Clear error states
    Provider.of<AuthenticationViewModel>(context, listen: false).clearErrors();

    // Dispose controllers
    passwordController.dispose();
    confirmPassController.dispose();
    emailController.dispose();
    usernameController.dispose();

    // Dispose focus nodes
    passwordFocusNode.dispose();
    confirmPassFocusNode.dispose();
    usernameFocusNode.dispose();

    super.dispose();
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
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _handlePasswordUpdate(AuthenticationViewModel authvm) async {
  setState(() {
    isLoading = true;
  });

  try {
    authvm.clearErrors();
    EmailPasswordAuthProvider authProvider = EmailPasswordAuthProvider(app);
    final currentUser = app.currentUser;
    final pass = passwordController.text.trim();
    final cPass = confirmPassController.text.trim();
    final userEmail = currentUser!.profile.email ?? '';

    // Clear any previous errors
    authvm.setPasswordError(null);
    authvm.setConfirmPasswordError(null);

    final passError = authvm.validatePasswordForSignUp(pass);
    final cPassError = authvm.validateConfirmPass(cPass, pass);

    if (authvm.allErrorChangePass != null) {
      authvm.setChangePassError(authvm.allErrorChangePass);
      showAwesomeSnackBar(
        context,
        "Error",
        authvm.allErrorChangePass!,
        ContentType.failure,
      );
      return;
    }

    if (authvm.passwordError != null) {
      authvm.setPasswordError(passError);
      showAwesomeSnackBar(
        context,
        "Error",
        authvm.passwordError!,
        ContentType.failure,
      );
      return;
    }
    if (authvm.confirmPassErrs != null) {
      authvm.setConfirmPasswordError(passError);
      showAwesomeSnackBar(
        context,
        "Error",
        authvm.confirmPassErrs!,
        ContentType.failure,
      );
      return;
    }

    // Try to login with the provided credentials
    final credentials = Credentials.emailPassword(userEmail, pass);
    await app.logIn(credentials);

    // Send reset password email - only call this once
    await authProvider.resetPassword(userEmail);

    // Show success dialog and navigate back to profile page
    await _showSuccessDialogAndNavigate();
  } catch (e) {
    String errorMessage = 'An error occurred';
    if (e is RealmException) {
      errorMessage = 'Incorrect password';
    }
    showAwesomeSnackBar(
      context,
      'Error',
      errorMessage,
      ContentType.failure,
    );
  } finally {
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }
}

// New method to show dialog and handle navigation
  Future<void> _showSuccessDialogAndNavigate() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Mail sent!"),
          content:
              Text("Please check your email for changing password request"),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                // First pop the dialog
                Navigator.of(context).pop();
                // Then navigate back to profile page
                openProfilePage(context); // This will go back to profile page
              },
            ),
          ],
        );
      },
    );
  }

  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Consumer<AuthenticationViewModel>(
          builder: (context, authvm, child) {
            return LoadingOverlay(
              isLoading: isLoading,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF0083AB), Color(0xFF003545)],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                icon: const Icon(Icons.chevron_left,
                                    color: Colors.white, size: 32),
                                onPressed: () {
                                  GoBack(context);
                                },
                              ),
                            ),
                            const Align(
                              alignment: Alignment.center,
                              child: Text(
                                'Change Password',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Please enter your current password',
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'RobotoCondensed',
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: TextFormFieldAuthen(
                          controller: passwordController,
                          hintText: "Password",
                          obscureText: !authvm.passwordVisible4,
                          focusNode: passwordFocusNode,
                          suffixIcon: IconButton(
                            icon: Icon(authvm.passwordVisible4
                                ? Icons.visibility
                                : Icons.visibility_off),
                            color: Colors.grey,
                            onPressed: () {
                              authvm.togglePasswordVisibility4();
                            },
                          ),
                          borderColor: authvm.passwordError != null
                              ? Colors.red
                              : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Please confirm your password',
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'RobotoCondensed',
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: TextFormFieldAuthen(
                          controller: confirmPassController,
                          hintText: "Confirm password",
                          obscureText: !authvm.passwordVisible5,
                          focusNode: confirmPassFocusNode,
                          suffixIcon: IconButton(
                            icon: Icon(authvm.passwordVisible5
                                ? Icons.visibility
                                : Icons.visibility_off),
                            color: Colors.grey,
                            onPressed: () {
                              authvm.togglePasswordVisibility5();
                            },
                          ),
                          borderColor: (authvm.passwordError != null ||
                                  authvm.confirmPassErrs != null)
                              ? Colors.red
                              : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Center(
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  // Dismiss keyboard
                                  FocusScope.of(context).unfocus();
                                  // Then handle password update
                                  _handlePasswordUpdate(authvm);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF342056),
                            fixedSize: const Size(300, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            isLoading ? '' : 'Change',
                            style: const TextStyle(
                              fontSize: 16,
                              fontFamily: 'RobotoCondensed',
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
