import 'package:flutter/foundation.dart';

class UsersController extends ChangeNotifier {
  void load() {
    notifyListeners();
  }
}
