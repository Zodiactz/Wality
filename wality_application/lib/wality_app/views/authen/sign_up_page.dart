import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wality_application/wality_app/repo/auth_service.dart';
import 'package:wality_application/wality_app/utils/awesome_snack_bar.dart';
import 'package:wality_application/wality_app/utils/constant.dart';
import 'package:wality_application/wality_app/utils/text_form_field_authen.dart';
import 'package:wality_application/wality_app/utils/navigator_utils.dart';
import 'package:wality_application/wality_app/views_models/authentication_vm.dart';
import 'package:wality_application/wality_app/models/user.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:realm/realm.dart';
import 'package:wality_application/wality_app/utils/LoadingOverlay.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordController2 = TextEditingController();
  final FocusNode usernameFocusNode = FocusNode();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode confirmPassFocusNote = FocusNode();
  final App app = App(AppConfiguration('wality-1-djgtexn'));

  final AuthService _authService = AuthService();
  bool isLoading = false;

  // String generateUid(int length) {
  //   const chars =
  //       'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  //   final random = Random();
  //   return List.generate(length, (index) => chars[random.nextInt(chars.length)])
  //       .join();
  // }

  Future<void> _handleSignUpUpdate(AuthenticationViewModel authvm) async {
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final pass = passwordController.text.trim();
    final confirmPass = passwordController2.text.trim();

    // Clear any previous errors
    authvm.setAllSignUpError(null);
    authvm.setUsernameError(null);
    authvm.setEmailError(null);
    authvm.setPasswordError(null);
    authvm.setConfirmPasswordError(null);

    authvm.validateAllSignUp(username, email, pass, confirmPass);



    if (authvm.allErrorSignUp != null) {
      authvm.setAllSignUpError(authvm.allErrorSignUp);
      showAwesomeSnackBar(
        context,
        "Error",
        authvm.allErrorSignUp!,
        ContentType.failure,
      );
      return;
    }

    if (authvm.usernameError != null) {
      authvm.setUsernameError(authvm.usernameError);
      showAwesomeSnackBar(
        context,
        "Username Error",
        authvm.usernameError!,
        ContentType.failure,
      );
      return;
    }

    if (authvm.emailError != null) {
      authvm.setEmailError(authvm.emailError);
      showAwesomeSnackBar(
        context,
        "Email Error",
        authvm.emailError!,
        ContentType.failure,
      );
      return;
    }

    if (authvm.passwordError != null) {
      authvm.setPasswordError(authvm.passwordError);
      showAwesomeSnackBar(
        context,
        "Password Error",
        authvm.passwordError!,
        ContentType.failure,
      );
      return;
    }

    if (authvm.confirmEmailError != null) {
      authvm.setConfirmPasswordError(authvm.confirmEmailError);
      showAwesomeSnackBar(
        context,
        "ConfirmPassword Error",
        authvm.confirmEmailError!,
        ContentType.failure,
      );
      return;
    }
  }

  void signUp(AuthenticationViewModel authenvm) async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      await _handleSignUpUpdate(authenvm);
      bool isValidForSignUp = authenvm.allErrorSignUp == null &&
          authenvm.usernameError == null &&
          authenvm.emailError == null &&
          authenvm.passwordError == null &&
          authenvm.confirmEmailError == null;

      if (isValidForSignUp) {
        setState(() {
          isLoading = true;
        });

        try {
          final credentials = Credentials.emailPassword(
            emailController.text.trim(),
            passwordController.text.trim(),
          );
          EmailPasswordAuthProvider authProvider =
              EmailPasswordAuthProvider(app);

          await authProvider.registerUser(
            emailController.text.trim(),
            passwordController.text.trim(),
          );

          final user = await app.logIn(credentials);

          final newUser = Users(
            userId: user.id,
            // uid: generateUid(6),
            userName: usernameController.text.trim(),
            email: emailController.text.trim(),
            currentMl: 0,
            totalMl: 0,
            botLiv: 0,
            profileImg_link: "",
            fillingLimit: 0,
            eventBot: 0,
            dayBot: 0,
            monthBot: 0,
            yearBot: 0,
            realName: '',
            sID: '',
            isAdmin: false,
            eventMl: 0,
          );

          final result = await _authService.createUser(newUser);

          if (result != null) {
            openHomePage(context);
          } else {
            showAwesomeSnackBar(
              context,
              "Sign-up Failed",
              "Failed to create user. Please try again.",
              ContentType.failure,
            );
          }
        } catch (e) {
          showAwesomeSnackBar(
            context,
            "Sign-up Failed",
            "Failed to create user. Please try again.",
            ContentType.failure,
          );
        } finally {
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
        }
      } else {
        // Call the function to show the error snackbar when validation fails
      }
    } else {
      showAwesomeSnackBar(
        context,
        "Form Error",
        "Please fill in all fields correctly.",
        ContentType.failure,
      );
    }
  }

   @override
  void dispose() {
    Provider.of<AuthenticationViewModel>(context, listen: false).clearErrors();

    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    passwordController2.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    usernameFocusNode.dispose();
    confirmPassFocusNote.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthenticationViewModel>(
        builder: (context, authenvm, child) {
      return LoadingOverlay(
        isLoading: isLoading,
        child: Scaffold(
          body: Listener(
            onPointerDown: (_) {
              FocusScope.of(context).unfocus();
            },
            child: SingleChildScrollView(
              physics: authenvm.isScrollable
                  ? const AlwaysScrollableScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              reverse: true,
              child: Container(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF0083AB),
                      Color.fromARGB(255, 33, 117, 143),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.1, 1.0],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: Column(
                    children: [
                      const SizedBox(height: 50),
                      Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 100),
                            child: Center(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 90),
                                    child: Image.asset(
                                      'assets/images/Logo.png',
                                      width: 220,
                                      height: 220,
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(top: 200),
                                    child: Text(
                                      'Wality',
                                      style: TextStyle(
                                        fontSize: 96,
                                        fontFamily: 'RobotoCondensed',
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 136, left: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.chevron_left,
                                    size: 32,
                                  ),
                                  color: Colors.white,
                                  onPressed: () {
                                    openChoosewayPage(context);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Center(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 50.0,
                                width: 300.0,
                                child: TextFormFieldAuthen(
                                  controller: usernameController,
                                  hintText: "Username",
                                  obscureText: false,
                                  focusNode: usernameFocusNode,
                                  onFieldSubmitted: (value) {
                                    FocusScope.of(context)
                                        .requestFocus(emailFocusNode);
                                  },
                                  borderColor: authenvm.usernameError != null
                                      ? Colors.red
                                      : Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                height: 50.0,
                                width: 300.0,
                                child: TextFormFieldAuthen(
                                  controller: emailController,
                                  hintText: "Email",
                                  obscureText: false,
                                  focusNode: emailFocusNode,
                                  onFieldSubmitted: (value) {
                                    FocusScope.of(context)
                                        .requestFocus(passwordFocusNode);
                                  },
                                  borderColor: authenvm.emailError != null
                                      ? Colors.red
                                      : Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                height: 50.0,
                                width: 300.0,
                                child: TextFormFieldAuthen(
                                  controller: passwordController,
                                  hintText: "Password",
                                  obscureText: !authenvm.passwordVisible1,
                                  focusNode: passwordFocusNode,
                                  suffixIcon: IconButton(
                                    icon: Icon(authenvm.passwordVisible1
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                    color: Colors.grey,
                                    onPressed: () {
                                      authenvm.togglePasswordVisibility1();
                                    },
                                  ),
                                  onFieldSubmitted: (value) {
                                    FocusScope.of(context)
                                        .requestFocus(confirmPassFocusNote);
                                  },
                                  borderColor: authenvm.passwordError != null
                                      ? Colors.red
                                      : Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                height: 50.0,
                                width: 300.0,
                                child: TextFormFieldAuthen(
                                  controller: passwordController2,
                                  hintText: "Confirm Password",
                                  obscureText: !authenvm.passwordVisible2,
                                  focusNode: confirmPassFocusNote,
                                  suffixIcon: IconButton(
                                    icon: Icon(authenvm.passwordVisible2
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                    color: Colors.grey,
                                    onPressed: () {
                                      authenvm.togglePasswordVisibility2();
                                    },
                                  ),
                                  borderColor: authenvm.confirmPassErrs != null
                                      ? Colors.red
                                      : Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 28),
                              ElevatedButton(
                                onPressed:
                                    isLoading ? null : () => signUp(authenvm),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF342056),
                                  fixedSize: const Size(300, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  isLoading ? 'Signing up...' : 'Sign up',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'RobotoCondensed',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 28),
                              GestureDetector(
                                onTap: () {
                                  openSignInPage(context);
                                },
                                child: const Text(
                                  "Already have an account ?",
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    fontFamily: 'RobotoCondensed',
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 60),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
