import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wality_application/wality_app/repo/auth_service.dart';
import 'package:wality_application/wality_app/repo/realm_service.dart';
import 'package:wality_application/wality_app/utils/navigator_utils.dart';
import 'package:wality_application/wality_app/utils/text_form_field_authen.dart';
import 'package:wality_application/wality_app/views_models/authentication_vm.dart';
import 'package:realm/realm.dart';
import 'package:wality_application/wality_app/models/user.dart';
import 'package:wality_application/wality_app/views_models/authentication_vm.dart';


class ChangeEmailAndPasswordPage extends StatelessWidget {
  ChangeEmailAndPasswordPage({super.key});
  final RealmService _realmService = RealmService();
  final AuthService _authService = AuthService();
  final TextEditingController emailController = TextEditingController();
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordController2 = TextEditingController();
  final FocusNode usernameFocusNode = FocusNode();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode confirmPassFocusNote = FocusNode();
  final App app = App(AppConfiguration('wality-1-djgtexn'));


    void signUp(AuthenticationViewModel authenvm) async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      bool isValidForSignUp = await authenvm.validateAllSignUp(
          usernameController.text,
          emailController.text,
          passwordController.text,
          passwordController2.text);

      if (isValidForSignUp) {
        try {
          final credentials = Credentials.emailPassword(
            emailController.text.trim(),
            passwordController.text.trim(),
          );
          EmailPasswordAuthProvider authProvider =
              EmailPasswordAuthProvider(app);

          // Register a new user
          await authProvider.registerUser(
            emailController.text.trim(),
            passwordController.text.trim(),
          );

          // Log the user in after registration
          final user = await app.logIn(credentials);

          // Create a User instance
          final newUser = Users(
              userId: user.id,
              uid: "123456",
              userName: usernameController.text.trim(),
              email: emailController.text.trim(),
              currentMl: 0,
              totalMl: 0,
              botLiv: 0,
              profileImg_link: "",
              fillingLimit: 0,
              eventBot: 0);

          // Call the service to create the user and handle the response
          final result = await _authService.createUser(newUser);

          if (result != null) {
            // Success: Navigate to homepage
            // openHomePage(context);
          } else {
            // Show error message from result
            // ScaffoldMessenger.of(context).showSnackBar(
            //   SnackBar(content: Text(result!)),
            // );
          }
        } catch (e) {
          print('Failed to sign up: $e');
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(content: Text('Sign-up failed: $e')),
          // );
        }
      } else {
        // showErrorSnackBar(authenvm);
      }
    } else {
      // Validation failed, show error messages
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Please fill in all fields correctly')),
      // );
    }
  }

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
                        'Change email and password',
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
                          'New email',
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
                            hintText: "",
                            obscureText: false,
                            focusNode: FocusNode(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.only(left: 30),
                          child: ElevatedButton(
                            onPressed: () async {
                              final userId = _realmService.getCurrentUserId();
                    // Collect the text from the TextFormField
                    final newUserEmail = emailController.text;

                    // Make sure the username isn't empty and the user is logged in
                    if (userId != null && newUserEmail.isNotEmpty) {
                      // Pass the new username to the update function
                      final result = await _authService.updateUserEmail(
                          userId, newUserEmail);

                      // Provide feedback to the user based on the result
                      if (result == null || result.contains('successfully')) {
                        openProfilePage(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(result)),
                        );
                      }
                    }
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
