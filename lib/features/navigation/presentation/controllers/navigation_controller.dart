import 'package:flutter/material.dart';

import '../state/navigation_state.dart';

class NavigationController extends ChangeNotifier {
  NavigationState _state = const NavigationState();

  NavigationState get state => _state;

  void changeIndex(int index) {
    if (index == _state.currentIndex) return;

    _state = _state.copyWith(
      currentIndex: index,
    );

    notifyListeners();
  }
}