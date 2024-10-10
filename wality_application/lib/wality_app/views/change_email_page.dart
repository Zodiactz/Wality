import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wality_application/wality_app/repo/auth_service.dart';
import 'package:wality_application/wality_app/repo/realm_service.dart';
import 'package:wality_application/wality_app/repo/user_service.dart';
import 'package:wality_application/wality_app/utils/navigator_utils.dart';
import 'package:wality_application/wality_app/utils/text_form_field_authen.dart';
import 'package:wality_application/wality_app/views/waterCheck/qr_scanner_page.dart';
import 'package:wality_application/wality_app/views_models/authentication_vm.dart';
import 'package:realm/realm.dart';
import 'package:wality_application/wality_app/models/user.dart';
import 'package:wality_application/wality_app/utils/LoadingOverlay.dart';

final App app = App(AppConfiguration('wality-1-djgtexn'));

class ChangeEmailPage extends StatefulWidget {
  const ChangeEmailPage({super.key});

  @override
  _ChangeEmailPageState createState() => _ChangeEmailPageState();
}

class _ChangeEmailPageState extends State<ChangeEmailPage> {
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
  Future<String?>? usernameFuture;
  final UserService _userService = UserService();
  late var oldUserId = "";
  late var oldEmail = "";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final userId = _realmService.getCurrentUserId();
    usernameFuture = _userService.fetchUsername(userId!);
    oldUserId = userId;
  }

  void changeEmail() async {
    setState(() {
      isLoading = true;
    });

    if (emailController.text.trim().isNotEmpty &&
        passwordController.text.trim().isNotEmpty) {
      try {
        final currentUser = app.currentUser;
        if (currentUser == null) {
          print('No user is currently logged in');
          setState(() {
            isLoading = false;
          });
          return;
        }

        // Step 1: Verify the current password
        final credentials = Credentials.emailPassword(
          currentUser.profile.email ?? '',
          passwordController.text.trim(),
        );

        try {
          await app.logIn(credentials);
          print('Password verification successful');
        } catch (e) {
          print('Password verification failed: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Incorrect password')),
          );
          setState(() {
            isLoading = false;
          });
          return;
        }

        // Step 2: Proceed with changing the email
        final newEmail = emailController.text.trim();

        if (newEmail == currentUser.profile.email) {
          print('New email is the same as the current email');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('New email is the same as the current email')),
          );
          setState(() {
            isLoading = false;
          });
          return;
        }

        EmailPasswordAuthProvider authProvider = EmailPasswordAuthProvider(app);

        try {
          await authProvider.registerUser(
            newEmail,
            passwordController.text.trim(),
          );
          print('User email changed successfully');
        } catch (e) {
          print('Error changing email: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error changing email: $e')),
          );
          setState(() {
            isLoading = false;
          });
          return;
        }

        // Step 3: Update user data in the backend (if necessary)
        try {
          final currentUserData = await _userService.fetchUserData(oldUserId);
          oldEmail = currentUserData?['email'];
          if (currentUserData != null) {
            final updatedUser = Users(
              userId: oldUserId,
              uid: currentUserData['uid'] ?? '',
              userName: currentUserData['username'] ?? 'Unknown',
              email: newEmail,
              currentMl: currentUserData['currentMl'] ?? 0,
              totalMl: currentUserData['totalMl'] ?? 0,
              botLiv: currentUserData['botLiv'] ?? 0,
              profileImg_link: currentUserData['profileImg_link'] ?? '',
              fillingLimit: currentUserData['fillingLimit'] ?? 0,
              startFillingTime: currentUserData['startFillingTime'],
              eventBot: currentUserData['eventBot'] ?? 0,
            );

            final result = await _authService.createUser(updatedUser);
            if (result != null) {
              print('User data updated successfully');
            } else {
              print('Failed to update user data');
            }
          }
        } catch (e) {
          print('Error updating user data: $e');
        }

        // Step 4: Log in with the new email
        try {
          final oldCredentials = Credentials.emailPassword(
              oldEmail, passwordController.text.trim());
          final oldUser = await app.logIn(oldCredentials);
          print("old email: $oldEmail");
          print("old user: $oldUser");
          await _userService.deleteUserByEmail(oldEmail);
          await app.deleteUser(oldUser);
          final newCredentials = Credentials.emailPassword(
              newEmail, passwordController.text.trim());
          final newUser = await app.logIn(newCredentials);
          print('Logged in with the new email successfully');
          await _userService.updateUserIdByEmal(newEmail, newUser.id);
          openProfilePage(context); // Redirect to profile page
        } catch (e) {
          print('Failed to log in with new email: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login failed: $e')),
          );
        }
      } catch (e) {
        print('Sign-up process failed: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign-up process failed: $e')),
        );
      } finally {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email and password cannot be empty')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthenticationViewModel>(
      builder: (context, authvm, child) {
        return LoadingOverlay(
          isLoading: isLoading,
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: Stack(
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
                            'Change Email',
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
                                hintText: "Email",
                                obscureText: false,
                                focusNode: emailFocusNode,
                                errorMessage: authvm.emailError,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Please enter your password to confirm the change',
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
                                errorMessage: authvm.passwordError,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.only(left: 30),
                              child: ElevatedButton(
                                onPressed: isLoading ? null : changeEmail,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF342056),
                                  fixedSize: const Size(300, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  isLoading ? 'Changing...' : 'Change',
                                  style: const TextStyle(
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
            ),
          ),
        );
      },
    );
  }
}