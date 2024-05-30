import 'package:flutter/material.dart';
import 'package:wality_application/InsideApp/SettingPage.dart';

class MachineBox extends StatefulWidget {
  const MachineBox({Key? key}) : super(key: key);

  @override
  State<MachineBox> createState() => _MachineBoxState();
}

class _MachineBoxState extends State<MachineBox> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 1, left: 20),
                child: Row(
                  children: [
                    Text(
                      'Machine A',
                      style: TextStyle(
                        fontSize: 24,
                        fontFamily: 'RobotoCondensed',
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Good',
                      style: TextStyle(
                        fontSize: 24,
                        fontFamily: 'RobotoCondensed',
                        color: Color(0xFF42B21B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
