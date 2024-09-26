import 'package:flutter/material.dart';
import 'package:wality_application/wality_app/utils/navigator_utils.dart';

Future popupChangeInfo(BuildContext context) async {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        titlePadding: const EdgeInsets.all(0),
        title: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top:8.0, right: 8.0),
              child: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(
                    Icons.close,
                    size: 32,
                  ),
                  onPressed: () {
                    GoBack(context);
                  },
                ),
              ),
            ),
            const Text(
              'Change Information',
              style: TextStyle(
                fontSize: 30,
                fontFamily: 'RobotoCondensed',
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            GestureDetector(
              onTap: () {},
              child: ClipOval(
                child: Image.asset(
                  'assets/images/cat.jpg',
                  width: 96,
                  height: 96,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Name',
              ),
            ),
          ],
        ),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {},
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
        ],
      );
    },
  );
}
