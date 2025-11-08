import 'package:flutter/material.dart';

class AuthUser {
  AuthUser({required this.name, required this.email});

  final String name;
  final String email;
}

class AuthNotifier extends ChangeNotifier {
  AuthNotifier({AuthUser? user, bool isGuest = false})
      : _user = user,
        _isGuest = isGuest;

  AuthUser? _user;
  bool _isGuest;

  AuthUser? get user => _user;
  bool get isGuest => _isGuest;
  bool get isAuthenticated => _user != null || _isGuest;

  void login(String email) {
    _user = AuthUser(name: 'Explorer', email: email);
    _isGuest = false;
    notifyListeners();
  }

  void guest() {
    _user = null;
    _isGuest = true;
    notifyListeners();
  }

  void logout() {
    _user = null;
    _isGuest = false;
    notifyListeners();
  }
}
