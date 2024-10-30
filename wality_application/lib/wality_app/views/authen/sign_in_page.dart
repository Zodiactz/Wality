// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wality_application/wality_app/utils/awesome_snack_bar.dart';
import 'package:wality_application/wality_app/utils/text_form_field_authen.dart';
import 'package:wality_application/wality_app/utils/navigator_utils.dart';
import 'package:wality_application/wality_app/views_models/authentication_vm.dart';
import 'package:realm/realm.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:wality_application/wality_app/utils/LoadingOverlay.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final App app = App(AppConfiguration('wality-1-djgtexn'));

  Future<void> _handleSignInUpdate(AuthenticationViewModel authvm) async {
    final email = emailController.text.trim();
    final pass = passwordController.text.trim();

    // Clear any previous errors
    authvm.setAllSignInError(null);
    authvm.setEmailError(null);
    authvm.setPasswordError(null);

    // Perform the validation
    authvm.validateAllSignIn(email, pass);

    if (authvm.allErrorSignIn != null) {
      authvm.setAllSignInError(authvm.allErrorSignIn);
      showAwesomeSnackBar(
        context,
        "Error",
        authvm.allErrorSignIn!,
        ContentType.failure,
      );
      return;
    }

    // Check email error first
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

    // Then check password error
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

    // If we reach here, all validations passed
    // You can proceed with sign in logic here
  }

  void signIn() async {
    setState(() {
      isLoading = true;
    });

    final email = emailController.text.trim();
    final pass = passwordController.text.trim();

    try {
      final emailPwCredentials = Credentials.emailPassword(email, pass);
      await app.logIn(emailPwCredentials);
      openHomePage(context);
    } on Exception {
      _handleSignInUpdate(context.read<AuthenticationViewModel>());
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthenticationViewModel>(
      builder: (context, authvm, child) {
        return LoadingOverlay(
          isLoading: isLoading,
          child: Scaffold(
            body: Listener(
              onPointerDown: (_) {
                if (emailFocusNode.hasFocus || passwordFocusNode.hasFocus) {
                  emailFocusNode.unfocus();
                  passwordFocusNode.unfocus();
                }
              },
              child: SingleChildScrollView(
                physics: authvm.isScrollable
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
                    padding: const EdgeInsets.only(top: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 100),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(height: 32),
                                    Image.asset(
                                      'assets/images/Logo.png',
                                      width: 220,
                                      height: 220,
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Wality',
                                      style: TextStyle(
                                        fontSize: 96,
                                        fontFamily: 'RobotoCondensed',
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 116, left: 8),
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
                                    controller: emailController,
                                    hintText: "Email",
                                    obscureText: false,
                                    focusNode: emailFocusNode,
                                    onFieldSubmitted: (value) {
                                      FocusScope.of(context)
                                          .requestFocus(passwordFocusNode);
                                    },
                                    borderColor: authvm.emailError != null
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
                                    borderColor: authvm.passwordError != null
                                        ? Colors.red
                                        : Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 28),
                                ElevatedButton(
                                  onPressed: isLoading ? null : signIn,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF342056),
                                    fixedSize: const Size(300, 50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    isLoading ? 'Signing in...' : 'Sign in',
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
                                    openSignUpPage(context);
                                  },
                                  child: const Text(
                                    "Haven't has an account yet?",
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      fontFamily: 'RobotoCondensed',
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 28),
                                GestureDetector(
                                  onTap: () {
                                    openForgotPassword(context);
                                  },
                                  child: const Text(
                                    "Forgot password?",
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
      },
    );
  }
}
