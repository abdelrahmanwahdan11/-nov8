import 'package:flutter/material.dart';

import '../../../data/services_local/preferences_service.dart';

class NotificationsNotifier extends ChangeNotifier {
  NotificationsNotifier({required this.preferencesService})
      : _read = preferencesService.loadReadNotifications().toSet();

  final PreferencesService preferencesService;
  final Set<String> _read;

  Set<String> get readIds => Set.unmodifiable(_read);

  bool isRead(String id) => _read.contains(id);

  bool markRead(String id) {
    final changed = _read.add(id);
    if (changed) {
      _persist();
      notifyListeners();
    }
    return changed;
  }

  bool markAll(Iterable<String> ids) {
    var changed = false;
    for (final id in ids) {
      if (_read.add(id)) {
        changed = true;
      }
    }
    if (changed) {
      _persist();
      notifyListeners();
    }
    return changed;
  }

  void reset() {
    if (_read.isEmpty) {
      return;
    }
    _read.clear();
    _persist();
    notifyListeners();
  }

  void _persist() {
    preferencesService.saveReadNotifications(_read.toList());
  }
}
