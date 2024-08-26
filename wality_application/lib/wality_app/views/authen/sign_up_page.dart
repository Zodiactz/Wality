import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wality_application/wality_app/utils/text_form_field_authen.dart';
import 'package:wality_application/wality_app/utils/navigator_utils.dart';
import 'package:wality_application/wality_app/views_models/authentication_vm.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _authenPageState();
}

class _authenPageState extends State<SignUpPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode usernameFocusNode = FocusNode();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    String? usernameError;
    String? emailError;
    String? passwordError;

    void showErrorSnackBar(AuthenticationViewModel authenvm) {
      authenvm.validateAllSignUp(usernameController.text, emailController.text,
          passwordController.text);

      if (authenvm.allError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authenvm.allError!)),
        );
      } else if (authenvm.usernameError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authenvm.usernameError!)),
        );
      } else if (authenvm.emailError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authenvm.emailError!)),
        );
      } else if (authenvm.passwordError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authenvm.passwordError!)),
        );
      }
    }

    void signUp(AuthenticationViewModel authenvm) async {
      if (_formKey.currentState != null && _formKey.currentState!.validate()) {
        bool isValidForSignUp = await authenvm.validateAllSignUp(
            usernameController.text,
            emailController.text,
            passwordController.text);

        if (isValidForSignUp) {
          try {
            // Send HTTP POST request to backend
            final response = await http.post(
              Uri.parse(
                  'http://localhost:8080/create'), // Replace with your backend URL
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: jsonEncode(<String, String>{
                'username': usernameController.text.trim(),
                'email': emailController.text.trim(),
                'password': passwordController.text.trim(),
              }),
            );

            // Check if the sign-up was successful
            if (response.statusCode == 200) {
              print("User created successfully: ${response.body}");
              Navigator.pushNamed(context, '/homepage');
            } else {
              print("Failed to create user: ${response.body}");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Sign-up failed: ${response.body}')),
              );
            }
          } catch (e) {
            print("Error during sign-up: $e");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error during sign-up: $e')),
            );
          }
        } else {
          // Validation failed, show error messages
          showErrorSnackBar(authenvm);
        }
      } else {
        // Form not valid, show error messages
        showErrorSnackBar(authenvm);
      }
    }

    return Consumer<AuthenticationViewModel>(
        builder: (context, authenvm, child) {
      return Scaffold(
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
                        padding: const EdgeInsets.only(top: 90),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
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
                        padding: const EdgeInsets.only(top: 68, left: 8),
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
                              controller: usernameController,
                              hintText: "Username",
                              obscureText: false,
                              focusNode: usernameFocusNode,
                              errorMessage: usernameError,
                              onfieldSubmitted: (value) {
                                FocusScope.of(context)
                                    .requestFocus(usernameFocusNode);
                              },
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
                              obscureText: !authenvm.passwordVisible,
                              focusNode: passwordFocusNode,
                              suffixIcon: IconButton(
                                icon: Icon(authenvm.passwordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off),
                                color: Colors.grey,
                                onPressed: () {
                                  authenvm.togglePasswordVisibility();
                                },
                              ),
                              errorMessage: passwordError,
                            ),
                          ),
                          const SizedBox(height: 28),
                          ElevatedButton(
                            onPressed: () {
                              signUp(authenvm);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF342056),
                              fixedSize: const Size(300, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Sign up',
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
      ));
    });
  }
}
