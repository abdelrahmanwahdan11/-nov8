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
        _allProperties = List<Property>.from(MockData.properties),
        _matches = List<Property>.from(MockData.properties),
        _results = List<Property>.from(MockData.properties) {
    _refreshFacets();
  }

  final List<String> _recent;
  Timer? _debounce;
  String _query = '';
  final List<_IndexedProperty> _indexed;
  final List<Property> _allProperties;
  List<Property> _matches;
  List<Property> _results;
  bool _isLoading = false;
  List<String> _popularTags = const [];
  List<String> _popularCities = const [];
  String? _activeTag;
  String? _activeTagNormalized;
  String? _activeCity;
  String? _activeCityNormalized;

  String get query => _query;
  List<Property> get results => _results;
  List<String> get recent => List.unmodifiable(_recent);
  bool get isLoading => _isLoading;
  List<String> get popularTags => List.unmodifiable(_popularTags);
  List<String> get popularCities => List.unmodifiable(_popularCities);
  int get activeRefinementCount =>
      (_activeTagNormalized != null ? 1 : 0) + (_activeCityNormalized != null ? 1 : 0);

  bool isTagActive(String tag) =>
      _activeTagNormalized != null && _activeTagNormalized == normalizeText(tag);

  bool isCityActive(String city) =>
      _activeCityNormalized != null && _activeCityNormalized == normalizeText(city);

  void toggleTag(String tag) {
    final normalized = normalizeText(tag);
    if (_activeTagNormalized == normalized) {
      _activeTag = null;
      _activeTagNormalized = null;
    } else {
      _activeTag = tag;
      _activeTagNormalized = normalized;
    }
    _applyFilters();
    notifyListeners();
  }

  void toggleCity(String city) {
    final normalized = normalizeText(city);
    if (_activeCityNormalized == normalized) {
      _activeCity = null;
      _activeCityNormalized = null;
    } else {
      _activeCity = city;
      _activeCityNormalized = normalized;
    }
    _applyFilters();
    notifyListeners();
  }

  void clearRefinements() {
    if (_activeTagNormalized == null && _activeCityNormalized == null) return;
    _activeTag = null;
    _activeTagNormalized = null;
    _activeCity = null;
    _activeCityNormalized = null;
    _applyFilters();
    notifyListeners();
  }

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
      _setMatches(_allProperties);
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    final normalizedQuery = normalizeText(trimmed);
    if (normalizedQuery.isEmpty) {
      _isLoading = false;
      _setMatches(_allProperties);
      notifyListeners();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 320), () async {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      final results = _indexed
          .where((entry) => entry.index.contains(normalizedQuery))
          .map((entry) => entry.property)
          .toList();
      _setMatches(results);
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
    _activeTag = null;
    _activeTagNormalized = null;
    _activeCity = null;
    _activeCityNormalized = null;
    _setMatches(_allProperties);
    _recent.clear();
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _setMatches(List<Property> matches) {
    _matches = List<Property>.from(matches);
    _refreshFacets();
    _applyFilters();
  }

  void _applyFilters() {
    if (_activeTagNormalized != null &&
        !_matches.any((property) => property.tags.any((tag) => normalizeText(tag) == _activeTagNormalized))) {
      _activeTag = null;
      _activeTagNormalized = null;
    }
    if (_activeCityNormalized != null &&
        !_matches.any((property) => normalizeText(property.city) == _activeCityNormalized)) {
      _activeCity = null;
      _activeCityNormalized = null;
    }

    Iterable<Property> filtered = _matches;
    if (_activeTagNormalized != null) {
      filtered = filtered.where(
        (property) => property.tags.any((tag) => normalizeText(tag) == _activeTagNormalized),
      );
    }
    if (_activeCityNormalized != null) {
      filtered = filtered.where(
        (property) => normalizeText(property.city) == _activeCityNormalized,
      );
    }
    _results = filtered.toList();
  }

  void _refreshFacets() {
    if (_matches.isEmpty) {
      _popularTags = const [];
      _popularCities = const [];
      return;
    }

    final tagAcc = <String, _FacetAccumulator>{};
    final cityAcc = <String, _FacetAccumulator>{};

    for (final property in _matches) {
      final cityKey = normalizeText(property.city);
      final cityFacet = cityAcc[cityKey];
      if (cityFacet != null) {
        cityFacet.increment();
      } else {
        cityAcc[cityKey] = _FacetAccumulator(property.city);
      }

      for (final tag in property.tags) {
        final tagKey = normalizeText(tag);
        final tagFacet = tagAcc[tagKey];
        if (tagFacet != null) {
          tagFacet.increment();
        } else {
          tagAcc[tagKey] = _FacetAccumulator(tag);
        }
      }
    }

    final sortedCities = cityAcc.values.toList()
      ..sort((a, b) => b.count.compareTo(a.count));
    final sortedTags = tagAcc.values.toList()
      ..sort((a, b) => b.count.compareTo(a.count));

    _popularCities = sortedCities.map((facet) => facet.label).take(6).toList();
    _popularTags = sortedTags.map((facet) => facet.label).take(6).toList();
  }
}

class _IndexedProperty {
  const _IndexedProperty({required this.property, required this.index});

  final Property property;
  final String index;
}

class _FacetAccumulator {
  _FacetAccumulator(this.label) : count = 1;

  final String label;
  int count;

  void increment() => count++;
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
