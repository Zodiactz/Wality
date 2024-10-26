import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:wality_application/wality_app/utils/custom_dropdown.dart';
import 'package:wality_application/wality_app/utils/constant.dart';
import 'package:realm/realm.dart';
import 'package:wality_application/wality_app/repo/realm_service.dart';
import 'package:wality_application/wality_app/repo/user_service.dart';
import 'package:flutter/src/widgets/async.dart' as flutter_async;
import 'package:wality_application/wality_app/utils/navigator_utils.dart';
import 'package:wality_application/wality_app/utils/text_form_field_authen.dart';
import 'package:wality_application/wality_app/views_models/authentication_vm.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode confirmPassFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(body:
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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 20.0),
                  child: Text(
                    'Reset Password Page',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 30, left: 15, right: 15),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'New Password',
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'RobotoCondensed',
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
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
                        const SizedBox(height: 40),
                        const Text(
                          'Please enter the same password to confirm the change',
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'RobotoCondensed',
                            color: Colors.white,
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
                        const SizedBox(height: 40),
                        Padding(
                          padding: const EdgeInsets.only(left: 30),
                          child: ElevatedButton(
                            onPressed: () {
                              //logic here
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
              ],
            ),
          ),
        ),
      );
    }));
  }
}
