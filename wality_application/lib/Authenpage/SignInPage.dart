import 'package:flutter/material.dart';
import 'package:wality_application/Authenpage/ChooseWayPage.dart';
import 'package:wality_application/Authenpage/ForgetPasswordPage.dart';
import 'package:wality_application/Authenpage/SignUpPage.dart';
import 'package:wality_application/InsideApp/HomePage.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  bool isScrollable = false;

  @override
  void initState() {
    super.initState();
    emailFocusNode.addListener(_onFocusChange);
    passwordFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    emailFocusNode.removeListener(_onFocusChange);
    passwordFocusNode.removeListener(_onFocusChange);
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      isScrollable = emailFocusNode.hasFocus || passwordFocusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Listener(
        onPointerDown: (_) {
          if (emailFocusNode.hasFocus || passwordFocusNode.hasFocus) {
            emailFocusNode.unfocus();
            passwordFocusNode.unfocus();
          }
        },
        child: SingleChildScrollView(
          physics: isScrollable ? AlwaysScrollableScrollPhysics() : NeverScrollableScrollPhysics(),
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
                              SizedBox(height: 32,),
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
                                  fontFamily: 'SairaCondensed',
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
                                icon: Icon(
                                  Icons.chevron_left,
                                  size: 32,
                                ),
                                color: Colors.black,
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ChooseWayPage(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          color: Colors.black,
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ChooseWayPage(),
                              ),
                            );
                          },
                        ),
                      
                    ],
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 50.0,
                          width: 300.0,
                          child: TextFormField(
                            focusNode: emailFocusNode,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                              hintText: 'Email',
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 50.0,
                          width: 300.0,
                          child: TextFormField(
                            focusNode: passwordFocusNode,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                              hintText: 'Password',
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => HomePage()),
                            );
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
                              fontFamily: 'SairaCondensed',
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignUpPage(),
                              ),
                            );
                          },
                          child: const Text(
                            "Haven’t has an account yet ?",
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontFamily: 'SairaCondensed',
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ForgetpasswordPage(),
                              ),
                            );
                          },
                          child: const Text(
                            "Forgot password ?",
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontFamily: 'SairaCondensed',
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
