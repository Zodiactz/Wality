import 'package:flutter/material.dart';

class ProfileViewModel extends ChangeNotifier {
  Divider buildDivider() {
    return const Divider(
      color: Colors.grey,
      thickness: 1,
      indent: 2,
      endIndent: 16,
    );
  }

  Flexible buildProfileOption(BuildContext context,
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return Flexible(
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6D8093).withOpacity(0.2),
              ),
              padding: const EdgeInsets.all(5.0),
              child: Icon(
                icon,
                size: 44,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontFamily: 'RobotoCondensed',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
