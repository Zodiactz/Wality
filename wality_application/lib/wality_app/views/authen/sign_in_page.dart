import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wality_application/wality_app/utils/awesome_snack_bar.dart';
import 'package:wality_application/wality_app/utils/text_form_field_authen.dart';
import 'package:wality_application/wality_app/utils/navigator_utils.dart';
import 'package:wality_application/wality_app/views_models/authentication_vm.dart';
import 'package:realm/realm.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final App app = App(AppConfiguration('wality-1-djgtexn'));

  @override
  Widget build(BuildContext context) {
    String? emailError;
    String? passwordError;


    void showErrorSnackBar(AuthenticationViewModel authenvm) {
      authenvm.validateAllSignIn(emailController.text, passwordController.text);

      if (authenvm.allError != null) {
        showAwesomeSnackBar(
          context,
          "Error",
          authenvm.allError!,
          ContentType.failure,
        );
      } else if (authenvm.emailError != null) {
        showAwesomeSnackBar(
          context,
          "Email Error",
          authenvm.emailError!,
          ContentType.failure,
        );
      } else if (authenvm.passwordError != null) {
        showAwesomeSnackBar(
          context,
          "Password Error",
          "Please enter your password",
          ContentType.failure,
        );
      } else{
        showAwesomeSnackBar(
          context,
          "Sign-in Failed",
          "Invalid email or password. Please try again.",
          ContentType.failure,
        );
      }
    }

    void signIn() async {
      final email = emailController.text.trim();
      final pass = passwordController.text.trim();
      try {
        final emailPwCredentials = Credentials.emailPassword(email, pass);
        await app.logIn(emailPwCredentials);
        openHomePage(context);
      } on Exception catch (e) {
        showErrorSnackBar(context.read<AuthenticationViewModel>());
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

    return Consumer<AuthenticationViewModel>(
      builder: (context, authenvm, child) {
        return Scaffold(
          body: Listener(
            onPointerDown: (_) {
              if (emailFocusNode.hasFocus || passwordFocusNode.hasFocus) {
                emailFocusNode.unfocus();
                passwordFocusNode.unfocus();
              }
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
                      Color(0xFFD6F1F3),
                      Color(0xFF0083AB),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.1, 1.0],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
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
                            padding: const EdgeInsets.only(top: 88, left: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.chevron_left,
                                    size: 32,
                                  ),
                                  color: Colors.black,
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
                                  errorMessage: emailError,
                                  onfieldSubmitted: (value) {
                                    FocusScope.of(context)
                                        .requestFocus(passwordFocusNode);
                                  },
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
                                  errorMessage: passwordError,
                                ),
                              ),
                              const SizedBox(height: 28),
                              ElevatedButton(
                                onPressed: () {
                                  signIn();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF342056),
                                  fixedSize: const Size(300, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Sign in',
                                  style: TextStyle(
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
                                  "Haven’t has an account yet?",
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
        );
      },
    );
  }
}
