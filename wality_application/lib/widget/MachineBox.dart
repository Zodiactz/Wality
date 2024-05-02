import 'package:flutter/material.dart';
import 'package:wality_application/InsideApp/SettingPage.dart';

class MachineBox extends StatefulWidget {
  const MachineBox({super.key});

  @override
  State<MachineBox> createState() => _MachineBoxState();
}

class _MachineBoxState extends State<MachineBox> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SettingPage()),
            );
          },
          child: Center(
                  child: Column(
                    children: [
                      Container(
                        width: 340,
                        height: 95,
                        decoration: const BoxDecoration(
                            color: Color(0xFFFFFFFF),
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.all(Radius.circular(20))),
                        child: Padding(
                          padding: const EdgeInsets.only(top:1, left: 20),
                          child: Row(
                            children: [
                              Text(
                                'Machine A',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontFamily: 'SairaCondensed',
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 160),
                                child: Text(
                                  'Good',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontFamily: 'SairaCondensed',
                                    color: Color(0xFF42B21B),
                                    fontWeight: FontWeight.bold,
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
        ),
      )
    );
  }
}