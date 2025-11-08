import 'package:flutter/material.dart';

class CompareNotifier extends ChangeNotifier {
  CompareNotifier({List<String>? initial}) : _ids = List<String>.from(initial ?? <String>[]);

  final List<String> _ids;

  List<String> get ids => List.unmodifiable(_ids);

  bool contains(String id) => _ids.contains(id);

  void toggle(String id) {
    if (_ids.contains(id)) {
      _ids.remove(id);
    } else {
      if (_ids.length >= 3) {
        _ids.removeAt(0);
      }
      _ids.add(id);
    }
    notifyListeners();
  }

  void remove(String id) {
    if (_ids.remove(id)) {
      notifyListeners();
    }
  }

  void clear() {
    if (_ids.isNotEmpty) {
      _ids.clear();
      notifyListeners();
    }
  }
}
