import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wality_application/wality_app/repo/realm_service.dart';
import 'package:wality_application/wality_app/repo/user_service.dart';
import 'package:wality_application/wality_app/utils/navigator_utils.dart';
import 'package:wality_application/wality_app/utils/text_form_field_authen.dart';
import 'package:wality_application/wality_app/views_models/authentication_vm.dart';
import 'package:realm/realm.dart';

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
              },
            ),
          ],
        );
      },
    );
  }

  void changePass() async {
    EmailPasswordAuthProvider authProvider = EmailPasswordAuthProvider(app);
    final currentUser = app.currentUser;
    final Pass = passwordController.text.trim();
    final cPass = confirmPassController.text.trim();
    final userEmail = currentUser!.profile.email ?? '';
    if (Pass.isNotEmpty && cPass.isNotEmpty) {
      if (Pass == cPass) {
        final credentials = Credentials.emailPassword(
          userEmail,
          Pass,
        );

        try {
          await app.logIn(credentials);
          print('Password verification successful');
          await app.emailPasswordAuthProvider.resetPassword(userEmail);
          try {
            await authProvider.resetPassword(userEmail);
            _showDialog("Mail sent!",
                "Please check your email for changing password request");
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Change Password Fail: $e')),
            );
          }
        } catch (e) {
          print('Password verification failed: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Incorrect password')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Password and confirm Password must be the same')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Password and confirm Password can not be empty')),
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left,
                            color: Colors.white, size: 32),
                        onPressed: () {
                          GoBack(context);
                        },
                      ),
                      const SizedBox(width: 24),
                      const Center(
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
                  const SizedBox(height: 40),
                  const Text(
                    'Current Password',
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'RobotoCondensed',
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormFieldAuthen(
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
                  const SizedBox(height: 30),
                  const Text(
                    'Confirm Current Password',
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'RobotoCondensed',
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormFieldAuthen(
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
                  const SizedBox(height: 40),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Call your change password function here
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
          ),
        );
      }),
    );
  }
}
