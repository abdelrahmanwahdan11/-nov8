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

  void login(String email, {String? name}) {
    final trimmed = name?.trim();
    final resolvedName =
        trimmed != null && trimmed.isNotEmpty ? trimmed : (_user?.name ?? 'Explorer');
    _user = AuthUser(name: resolvedName, email: email);
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

  void updateProfile(String name) {
    final trimmed = name.trim();
    if (_user != null && trimmed.isNotEmpty) {
      _user = AuthUser(name: trimmed, email: _user!.email);
      notifyListeners();
    }
  }
}
