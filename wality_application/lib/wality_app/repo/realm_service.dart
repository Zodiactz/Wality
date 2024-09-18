import 'package:realm/realm.dart';

class RealmService {
  final App _app;

  RealmService() : _app = App(AppConfiguration('wality-1-djgtexn'));

  // Method to get the current user ID
  String? getCurrentUserId() {
    return _app.currentUser?.id;
  }

  // Method to get the app instance
  App get app => _app;
}
