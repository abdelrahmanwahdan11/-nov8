import 'package:flutter/material.dart';

class FavoritesNotifier extends ChangeNotifier {
  FavoritesNotifier({List<String>? initial})
      : _ids = List<String>.from(initial ?? <String>[]);

  final List<String> _ids;

  List<String> get ids => List.unmodifiable(_ids);

  bool isFavorite(String id) => _ids.contains(id);

  void toggle(String id) {
    if (_ids.contains(id)) {
      _ids.remove(id);
    } else {
      _ids.add(id);
    }
    notifyListeners();
  }

  void clear() {
    if (_ids.isNotEmpty) {
      _ids.clear();
      notifyListeners();
    }
  }
}
