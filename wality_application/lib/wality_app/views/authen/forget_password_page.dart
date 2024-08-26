import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wality_application/wality_app/utils/text_form_field_authen.dart';
import 'package:wality_application/wality_app/utils/navigator_utils.dart';
import 'package:wality_application/wality_app/views_models/authentication_vm.dart';

class ForgetpasswordPage extends StatefulWidget {
  const ForgetpasswordPage({super.key});

  @override
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
    String? emailError;
    String? confirmEmailError;

     void showErrorSnackBar(AuthenticationViewModel authenvm) {
      authenvm.validateAllForgetPassword(
        emailController.text,
        confirmEmailController.text,);

      if (authenvm.allError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authenvm.allError!)),
        );
      } else if (authenvm.emailError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authenvm.emailError!)),
        );
      } else if (authenvm.confirmEmailError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authenvm.confirmEmailError!)),
        );
      }
    }

    void confirmEmail(AuthenticationViewModel authenvm) async {
      if (_formKey.currentState != null && _formKey.currentState!.validate()) {
        bool isValidForConfirmEmail = await authenvm.validateAllForgetPassword(
          emailController.text,
          confirmEmailController.text,
        );

        if (isValidForConfirmEmail) {
          Navigator.pushNamed(context, '/choosewaypage');
        } else {
          showErrorSnackBar(authenvm);
        }
      } else {
        showErrorSnackBar(authenvm);
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
                          padding: const EdgeInsets.only(top: 80),
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
                          padding: const EdgeInsets.only(top: 20, left: 8),
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
                                  SizedBox(
                                    height: 50.0,
                                    width: 300.0,
                                    child: TextFormFieldAuthen(
                                      controller: emailController,
                                      hintText: "Email",
                                      obscureText: false,
                                      focusNode: emailFocusNode,
                                      errorMessage:emailError,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    height: 50.0,
                                    width: 300.0,
                                    child: TextFormFieldAuthen(
                                      controller: confirmEmailController,
                                      hintText: "Confirm Email",
                                      obscureText: false,
                                      focusNode: confirmEmailFocusNode,
                                      errorMessage: confirmEmailError,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 28),
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
