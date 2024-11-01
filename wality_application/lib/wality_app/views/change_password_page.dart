import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wality_application/wality_app/repo/realm_service.dart';
import 'package:wality_application/wality_app/repo/user_service.dart';
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
    authvm.clearErrors();
    EmailPasswordAuthProvider authProvider = EmailPasswordAuthProvider(app);
    final currentUser = app.currentUser;
    final pass = passwordController.text.trim();
    final cPass = confirmPassController.text.trim();
    final userEmail = currentUser!.profile.email ?? '';

    
    // Clear any previous errors
    authvm.setPasswordError(null);
    authvm.setConfirmPasswordError(null);

    final passError = authvm.validatePasswordForSignIn(pass);
    final cPassError = authvm.validateConfirmPass(cPass , pass);
    if (passError != null) {
      authvm.setPasswordError(passError);
      showAwesomeSnackBar(
        context,
        "Error",
        passError,
        ContentType.failure,
      );
      return;
    }
    if (cPassError != null) {
      authvm.setConfirmPasswordError(cPass);
      showAwesomeSnackBar(
        context,
        "Error",
        cPassError,
        ContentType.failure,
      );
      return;
    }
    if (passError != null && cPassError != null) {
      final combinedError = '$passError\n$cPassError';
      showAwesomeSnackBar(
      context,
      "Error",
      combinedError,
      ContentType.failure,
      );
      return;
    }

    
    if (pass.isNotEmpty && cPass.isNotEmpty) {
      if (pass == cPass) {
        final credentials = Credentials.emailPassword(
          userEmail,
          pass,
        );

        try {
          await app.logIn(credentials);
          await app.emailPasswordAuthProvider.resetPassword(userEmail);
          try {
            await authProvider.resetPassword(userEmail);
            _showDialog("Mail sent!",
                "Please check your email for changing password request");
          } catch (e) {
            showAwesomeSnackBar(
              context,
              'Error',
              'Change Password Fail: $e',
              ContentType.failure,
            );
          }
        } catch (e) {
          showAwesomeSnackBar(
            context,
            'Error',
            'Incorrect password',
            ContentType.failure,
          );
        }
      } else {
        showAwesomeSnackBar(
          context,
          'Error',
          'Password and confirm Password must be the same',
          ContentType.failure,
        );
      }
    } else {
      showAwesomeSnackBar(
        context,
        'Error',
        'Please fill in all fields',
        ContentType.failure,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
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
                    borderColor:
                        authvm.passwordError != null ? Colors.red : Colors.grey,
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
                    borderColor: (authvm.passwordError != null || authvm.confirmPassErrs != null) 
                        ? Colors.red
                        : Colors.grey,
                  ),
                ),
                const SizedBox(height: 40),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      _handlePasswordUpdate(authvm);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF342056),
                      fixedSize: const Size(300, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
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
              ],
            ),
          ),
        );
      }),
    );
  }
}