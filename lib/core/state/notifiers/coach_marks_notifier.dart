import 'package:flutter/material.dart';

class CoachMarksNotifier extends ChangeNotifier {
  CoachMarksNotifier({bool isFirstRun = true}) : _isFirstRun = isFirstRun;

  bool _isFirstRun;

  bool get shouldShow => _isFirstRun;

  void complete() {
    if (_isFirstRun) {
      _isFirstRun = false;
      notifyListeners();
    }
  }
}
