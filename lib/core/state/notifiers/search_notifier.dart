import 'dart:async';

import 'package:flutter/material.dart';

import '../../utils/text_normalizer.dart';
import '../../../data/mocks/mock_data.dart';
import '../../../data/models/property.dart';

class SearchNotifier extends ChangeNotifier {
  SearchNotifier({List<String>? initialRecent})
      : _recent = List<String>.from(initialRecent ?? <String>[]),
        _indexed = MockData.properties
            .map((property) => _IndexedProperty(property: property, index: _composeIndex(property)))
            .toList(),
        _results = _indexed.map((entry) => entry.property).toList();

  final List<String> _recent;
  Timer? _debounce;
  String _query = '';
  List<Property> _results;
  bool _isLoading = false;
  final List<_IndexedProperty> _indexed;

  String get query => _query;
  List<Property> get results => _results;
  List<String> get recent => List.unmodifiable(_recent);
  bool get isLoading => _isLoading;

  List<String> suggestions(String input) {
    final query = input.trim();
    if (query.isEmpty) {
      return List<String>.from(_recent.take(6));
    }
    final normalizedQuery = normalizeText(query);
    if (normalizedQuery.isEmpty) {
      return List<String>.from(_recent.take(6));
    }

    final seen = <String>{};
    final results = <String>[];

    void addCandidate(String candidate) {
      if (candidate.isEmpty) return;
      final normalizedCandidate = normalizeText(candidate);
      if (!normalizedCandidate.contains(normalizedQuery)) return;
      if (seen.add(normalizedCandidate)) {
        results.add(candidate);
      }
    }

    for (final recent in _recent) {
      addCandidate(recent);
      if (results.length >= 8) {
        return results;
      }
    }

    for (final entry in _indexed) {
      addCandidate(entry.property.title);
      if (results.length >= 8) break;
      addCandidate(entry.property.city);
      if (results.length >= 8) break;
      for (final token in entry.property.city.split(RegExp(r'\s+'))) {
        addCandidate(token);
        if (results.length >= 8) break;
      }
      for (final token in entry.property.title.split(RegExp(r'\s+'))) {
        addCandidate(token);
        if (results.length >= 8) break;
      }
      for (final tag in entry.property.tags) {
        addCandidate(tag);
        if (results.length >= 8) break;
      }
      if (results.length >= 8) break;
    }

    return results;
  }

  void updateQuery(String value) {
    _query = value;
    _debounce?.cancel();
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      _isLoading = false;
      _results = _indexed.map((entry) => entry.property).toList();
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    final normalizedQuery = normalizeText(trimmed);
    if (normalizedQuery.isEmpty) {
      _isLoading = false;
      _results = _indexed.map((entry) => entry.property).toList();
      notifyListeners();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 320), () async {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      final results = _indexed
          .where((entry) => entry.index.contains(normalizedQuery))
          .map((entry) => entry.property)
          .toList();
      _results = results;
      _isLoading = false;
      notifyListeners();
    });
  }

  void commitQuery(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    final normalized = normalizeText(trimmed);
    final existingIndex = _recent.indexWhere((element) => normalizeText(element) == normalized);
    if (existingIndex != -1) {
      _recent.removeAt(existingIndex);
    }
    _recent.insert(0, trimmed);
    if (_recent.length > 6) {
      _recent.removeLast();
    }
    notifyListeners();
  }

  void reset() {
    _debounce?.cancel();
    _query = '';
    _results = _indexed.map((entry) => entry.property).toList();
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

class _IndexedProperty {
  const _IndexedProperty({required this.property, required this.index});

  final Property property;
  final String index;
}

String _composeIndex(Property property) {
  final buffer = StringBuffer()
    ..write(property.title)
    ..write(' ')
    ..write(property.city)
    ..write(' ')
    ..write(property.description)
    ..write(' ')
    ..write(property.facilities.beds)
    ..write(' beds ')
    ..write(property.facilities.baths)
    ..write(' baths ')
    ..write(property.facilities.area)
    ..write(' area ')
    ..write(property.facilities.parking)
    ..write(' parking ')
    ..write(property.facilities.garden)
    ..write(' garden ')
    ..writeAll(property.tags, ' ');
  return normalizeText(buffer.toString());
}
