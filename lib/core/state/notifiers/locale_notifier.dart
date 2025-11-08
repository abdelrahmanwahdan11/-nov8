import 'package:flutter/material.dart';

class LocaleNotifier extends ChangeNotifier {
  LocaleNotifier(this._locale);

  Locale _locale;

  Locale get locale => _locale;

  void update(Locale locale) {
    if (_locale != locale) {
      _locale = locale;
      notifyListeners();
    }
  }
}
