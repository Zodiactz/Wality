import 'package:flutter/material.dart';
import 'package:wality_application/Authenpage/ChooseWayPage.dart';

class ForgetpasswordPage extends StatefulWidget {
  const ForgetpasswordPage({super.key});

  @override
  _ForgetpasswordPageState createState() => _ForgetpasswordPageState();
}

class _ForgetpasswordPageState extends State<ForgetpasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _confirmEmailController = TextEditingController();



  @override
  Widget build(BuildContext context) {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
              Padding(
                padding: const EdgeInsets.fromLTRB(5, 20, 0, 0),
                child: Stack(
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
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
                            SingleChildScrollView(
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 50.0,
                                    width: 300.0,
                                    child: TextFormField(
                                      controller: _emailController,
                                      decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.all(16),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(24),
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
                                      controller: _confirmEmailController,
                                      decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.all(16),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(24),
                                          borderSide: BorderSide.none,
                                        ),
                                        hintText: 'Confirm Email',
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const ChooseWayPage()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF342056),
                                fixedSize: const Size(300, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      10), 
                                ),
                              ),
                              child: const Text(
                                'Send Email',
                                style: TextStyle(
                                  fontSize: 16,
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
                    
                  ],
                ),
              ),
        ],
        ),
          ),
        
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _confirmEmailController.dispose();
    super.dispose();
  }
}
