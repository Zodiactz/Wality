import 'dart:io';
import 'dart:math';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wality_application/wality_app/utils/awesome_snack_bar.dart';
import 'package:wality_application/wality_app/utils/text_form_field_authen.dart';
import 'package:wality_application/wality_app/utils/navigator_utils.dart';
import 'package:wality_application/wality_app/views_models/authentication_vm.dart';

class ForgetpasswordPage extends StatefulWidget {
  const ForgetpasswordPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ForgetpasswordPageState createState() => _ForgetpasswordPageState();
}

class _ForgetpasswordPageState extends State<ForgetpasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController confirmEmailController = TextEditingController();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode confirmEmailFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    Future<void> _handleForgetPassword(AuthenticationViewModel authvm) async {
      final email = emailController.text.trim();

      // Clear any previous errors
      authvm.setAllSignInError(null);
      authvm.setEmailError(null);
      authvm.setPasswordError(null);

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
      } else {
        authvm.setAllSignInError(authvm.allErrorSignIn);
        showAwesomeSnackBar(
          context,
          "Error",
          authvm.allErrorSignIn!,
          ContentType.failure,
        );
      }
    }

    void confirmEmail(AuthenticationViewModel authenvm) async {
      if (_formKey.currentState != null && _formKey.currentState!.validate()) {
        bool isValidForConfirmEmail = await authenvm.validateAllForgetPassword(
          emailController.text,
        );

        if (isValidForConfirmEmail) {
          // ignore: use_build_context_synchronously
          openChoosewayPageFromLogoPage(context);
        } else {
          _handleForgetPassword(authenvm);
        }
      }
    }

    return Consumer<AuthenticationViewModel>(
        builder: (context, authenvm, child) {
      return Scaffold(
        body: SingleChildScrollView(
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
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 60),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  height: 32,
                                ),
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
                          padding: const EdgeInsets.only(top: 28, left: 8),
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
                                  GoBack(context);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Form(
                      key: _formKey,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 8),
                            SingleChildScrollView(
                              child: Column(
                                children: [
                                  const Text(
                                    'Please enter your email to reset your password',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'RobotoCondensed',
                                      fontWeight: FontWeight.normal,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 12,),
                                  SizedBox(
                                    height: 50.0,
                                    width: 300.0,
                                    child: TextFormFieldAuthen(
                                      controller: emailController,
                                      hintText: "Email",
                                      obscureText: false,
                                      focusNode: emailFocusNode,
                                      onFieldSubmitted: (value) {
                                        FocusScope.of(context).requestFocus(
                                            confirmEmailFocusNode);
                                      },
                                      borderColor: authenvm.emailError != null
                                          ? Colors.red
                                          : Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () {
                                confirmEmail(authenvm);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF342056),
                                fixedSize: const Size(300, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Confirm',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'RobotoCondensed',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ),
      );
    });
  }
}
