import 'package:flutter/material.dart';

import '../../../data/mocks/mock_data.dart';
import '../../../data/models/property.dart';

class SearchNotifier extends ChangeNotifier {
  SearchNotifier({List<String>? initialRecent})
      : _recent = List<String>.from(initialRecent ?? <String>[]);

  String _query = '';
  List<Property> _results = MockData.properties;
  final List<String> _recent;

  String get query => _query;
  List<Property> get results => _results;
  List<String> get recent => List.unmodifiable(_recent);

  List<String> suggestions(String input) {
    final normalized = input.toLowerCase();
    final source = <String>{
      for (final property in MockData.properties) ...{
        property.title,
        property.city,
        property.description,
        ...property.tags,
      },
    };
    return source
        .where((element) => element.toLowerCase().contains(normalized))
        .take(8)
        .toList();
  }

  void updateQuery(String value) {
    _query = value;
    if (value.isEmpty) {
      _results = MockData.properties;
    } else {
      final normalized = value.toLowerCase();
      _results = MockData.properties.where((property) {
        final text = '${property.title} ${property.city} ${property.description} '
            '${property.facilities.beds} beds ${property.facilities.baths} baths ${property.tags.join(' ')}';
        return text.toLowerCase().contains(normalized);
      }).toList();
    }
    notifyListeners();
  }

  void commitQuery(String value) {
    if (value.trim().isEmpty) return;
    _recent.remove(value);
    _recent.insert(0, value);
    if (_recent.length > 6) {
      _recent.removeLast();
    }
    notifyListeners();
  }
}
