import 'dart:async';

import 'package:flutter/material.dart';

import '../../../data/mocks/mock_data.dart';
import '../../../data/models/property.dart';

class SearchNotifier extends ChangeNotifier {
  SearchNotifier({List<String>? initialRecent})
      : _recent = List<String>.from(initialRecent ?? <String>[]),
        _results = List<Property>.from(MockData.properties);

  final List<String> _recent;
  Timer? _debounce;
  String _query = '';
  List<Property> _results;
  bool _isLoading = false;

  String get query => _query;
  List<Property> get results => _results;
  List<String> get recent => List.unmodifiable(_recent);
  bool get isLoading => _isLoading;

  List<String> suggestions(String input) {
    final query = input.trim();
    if (query.isEmpty) {
      return List<String>.from(_recent.take(6));
    }
    final normalized = query.toLowerCase();
    final source = <String>{
      for (final property in MockData.properties) ...{
        property.title,
        property.city,
        property.description,
        ...property.tags,
      },
    };
    final combined = <String>[
      ..._recent.where((element) => element.toLowerCase().contains(normalized)),
      ...source.where((element) => element.toLowerCase().contains(normalized)),
    ];
    final seen = <String>{};
    final results = <String>[];
    for (final value in combined) {
      final key = value.toLowerCase();
      if (seen.add(key)) {
        results.add(value);
      }
      if (results.length >= 8) {
        break;
      }
    }
    return results;
  }

  void updateQuery(String value) {
    _query = value;
    _debounce?.cancel();
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      _isLoading = false;
      _results = List<Property>.from(MockData.properties);
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    final scheduledQuery = trimmed.toLowerCase();
    _debounce = Timer(const Duration(milliseconds: 320), () async {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      final results = MockData.properties.where((property) {
        final text = '${property.title} ${property.city} ${property.description} '
            '${property.facilities.beds} beds ${property.facilities.baths} baths ${property.tags.join(' ')}';
        return text.toLowerCase().contains(scheduledQuery);
      }).toList();
      _results = results;
      _isLoading = false;
      notifyListeners();
    });
  }

  void commitQuery(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    _recent.remove(trimmed);
    _recent.insert(0, trimmed);
    if (_recent.length > 6) {
      _recent.removeLast();
    }
    notifyListeners();
  }

  void reset() {
    _debounce?.cancel();
    _query = '';
    _results = List<Property>.from(MockData.properties);
    _recent.clear();
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
