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
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode confirmPassFocusNode = FocusNode();
  final App app = App(AppConfiguration('wality-1-djgtexn'));
  Future<String?>? usernameFuture;
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    final userId = _realmService.getCurrentUserId();
    usernameFuture = _userService.fetchUsername(userId!);
    _fetchCurrentemail();
  }

  Future<void> _fetchCurrentemail() async {
    final userId = _realmService.getCurrentUserId();
    if (userId != null) {
      final currentEmail = await _userService.fetchEmail(userId);
      emailController.text = currentEmail ?? '';
    }
  } 
  void changePassword() async {
  // Unfocus the text fields to make sure the input is registered
  emailFocusNode.unfocus();
  passwordFocusNode.unfocus();

  // Print the values to ensure they're being captured
  print('Email: ${emailController.text}');
  print('Password: ${passwordController.text}');

  if (emailController.text.trim().isEmpty || passwordController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Email and password cannot be empty')),
    );
    return;
  }

  try {
    final credentials = Credentials.emailPassword(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    EmailPasswordAuthProvider authProvider = EmailPasswordAuthProvider(app);

    try {
      // Register a new user
      await authProvider.registerUser(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
      print('User registered successfully');
    } catch (e) {
      print('Error registering user: $e');
    }

    try {
      // Fetch the current user data
      final userId = _realmService.getCurrentUserId();
      final currentUserData = await _userService.fetchUserData(userId!);
      print('Current user data: $currentUserData');

      if (currentUserData != null) {
        // Create a User instance with updated email but handle null fields properly
        final newUser = Users(
          userId: userId,
          uid: currentUserData['uid'] ?? '',
          userName: currentUserData['username'] ?? 'Unknown',
          email: emailController.text.trim(),
          currentMl: currentUserData['currentMl'] ?? 0,
          totalMl: currentUserData['totalMl'] ?? 0,
          botLiv: currentUserData['botLiv'] ?? 0,
          profileImg_link: currentUserData['profileImg_link'] ?? '',
          fillingLimit: currentUserData['fillingLimit'] ?? 0,
          startFillingTime: currentUserData['startFillingTime'],
          eventBot: currentUserData['eventBot'] ?? 0,
        );

        // Call the service to create the user and handle the response
        final result = await _authService.createUser(newUser);

        if (result != null) {
          final emailPW = Credentials.emailPassword(
              emailController.text.trim(), passwordController.text.trim());
          await app.logIn(emailPW);
          print('User logged in successfully');

          openProfilePage(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to create user')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User data is null')),
        );
      }
    } catch (e) {
      print('Error logging in user: $e');
    }
  } catch (e) {
    print('Failed to sign up: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sign-up failed: $e')),
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
                          'Email',
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
                            controller: emailController,
                            hintText: "Email",
                            obscureText: false,
                            focusNode: emailFocusNode,
                           
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Please enter the new password',
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
                            hintText: "New Password",
                            obscureText: !authvm.passwordVisible1,
                            focusNode: passwordFocusNode,
                            errorMessage: authvm.passwordError,
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
                        Padding(
                          padding: const EdgeInsets.only(left: 30),
                          child: ElevatedButton(
                            onPressed: () {
                              // Directly call signUp without validation
                              changePassword();
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
