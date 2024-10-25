import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wality_application/wality_app/repo/auth_service.dart';
import 'package:wality_application/wality_app/repo/realm_service.dart';
import 'package:wality_application/wality_app/repo/user_service.dart';
import 'package:wality_application/wality_app/utils/navigator_utils.dart';
import 'package:wality_application/wality_app/utils/text_form_field_authen.dart';
import 'package:wality_application/wality_app/views_models/authentication_vm.dart';
import 'package:realm/realm.dart';
import 'package:wality_application/wality_app/models/user.dart';
import 'package:wality_application/wality_app/views_models/authentication_vm.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final RealmService _realmService = RealmService();
  final AuthService _authService = AuthService();
  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();
  final FocusNode usernameFocusNode = FocusNode();
  final AuthenticationViewModel authvm = AuthenticationViewModel();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode confirmPassFocusNode = FocusNode();
  final App app = App(AppConfiguration('wality-1-djgtexn'));
  final EmailPasswordAuthProvider authP =
      EmailPasswordAuthProvider(App(AppConfiguration('wality-1-djgtexn')));
  Future<String?>? usernameFuture;
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    final userId = _realmService.getCurrentUserId();
    usernameFuture = _userService.fetchUsername(userId!);
  }

  void changePass() async {
    final newPass = passwordController.text.trim();
    final cNewPass = confirmPassController.text.trim();
    if (newPass.isNotEmpty && cNewPass.isNotEmpty) {
      if (authvm.isPasswordValidate(newPass)) {
        if (newPass != cNewPass) {
          final currentUser = app.currentUser;
          try {
            await authP.callResetPasswordFunction(
                currentUser!.profile.email!, newPass);
            openProfilePage(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(
                      'Passowrd changed successfully!')),
            );
          } catch (e) {
            print('Change Password Fail: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Sign-up process failed: $e')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password must be the same only')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Password must be at least 8 characters long and contain at least 1 uppercase letter, 1 lowercase letter, 1 digit and 1 special character')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Password and confirm Password can not be empty')),
      );
    }
  }

  //await authProvider.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body:
          Consumer<AuthenticationViewModel>(builder: (context, authvm, child) {
        return Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              child: Container(
                width: double.maxFinite,
                height: 180,
                decoration: const BoxDecoration(
                  color: Color(0xFF0083AB),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.chevron_left,
                          size: 32,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          GoBack(context);
                        },
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Change Password',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'RobotoCondensed',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 150,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height - 150,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, left: 15, right: 15),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'New Password',
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'RobotoCondensed',
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
                        const SizedBox(height: 16),
                        const Text(
                          'Please enter the same password to confirm the change',
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'RobotoCondensed',
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
                            errorMessage: authvm.confirmEmailError,
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
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.only(left: 30),
                          child: ElevatedButton(
                            onPressed: () {
                              // Directly call signUp without validation
                              changePass();
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
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}