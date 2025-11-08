import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import '../../utils/text_normalizer.dart';
import '../../../data/mocks/mock_data.dart';
import '../../../data/models/property.dart';

const String _defaultSavedLabel = 'Search';

class SearchNotifier extends ChangeNotifier {
  SearchNotifier({List<String>? initialRecent, List<String>? initialSaved})
      : _recent = List<String>.from(initialRecent ?? <String>[]),
        _savedSearches = _decodeSaved(initialSaved),
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
  final List<SavedSearchEntry> _savedSearches;

  String get query => _query;
  List<Property> get results => _results;
  List<String> get recent => List.unmodifiable(_recent);
  bool get isLoading => _isLoading;
  List<String> get popularTags => List.unmodifiable(_popularTags);
  List<String> get popularCities => List.unmodifiable(_popularCities);
  int get activeRefinementCount =>
      (_activeTagNormalized != null ? 1 : 0) + (_activeCityNormalized != null ? 1 : 0);
  List<SavedSearchEntry> get savedSearches => List.unmodifiable(_savedSearches);
  List<String> get savedSearchStorage =>
      _savedSearches.map((entry) => entry.toStorageString()).toList(growable: false);
  bool get canSaveCurrent =>
      _query.trim().isNotEmpty || _activeTagNormalized != null || _activeCityNormalized != null;

  String suggestedLabelForCurrent() {
    final trimmed = _query.trim();
    if (trimmed.isNotEmpty) {
      return trimmed.length > 32 ? '${trimmed.substring(0, 32)}…' : trimmed;
    }
    final parts = <String>[];
    if (_activeCity != null && _activeCity!.isNotEmpty) {
      parts.add(_activeCity!);
    }
    if (_activeTag != null && _activeTag!.isNotEmpty) {
      parts.add('#${_activeTag!}');
    }
    if (parts.isEmpty) {
      return _defaultSavedLabel;
    }
    return parts.join(' • ');
  }

  bool isTagActive(String tag) =>
      _activeTagNormalized != null && _activeTagNormalized == normalizeText(tag);

  bool isCityActive(String city) =>
      _activeCityNormalized != null && _activeCityNormalized == normalizeText(city);

  SavedSearchSaveResult saveCurrent({String? label}) {
    final trimmed = _query.trim();
    if (!canSaveCurrent) {
      return SavedSearchSaveResult(entry: null, isUpdate: false);
    }

    final normalizedQuery = normalizeText(trimmed);
    final normalizedTag = _activeTagNormalized;
    final normalizedCity = _activeCityNormalized;
    final existingIndex = _savedSearches.indexWhere(
      (entry) =>
          entry.normalizedQuery == normalizedQuery &&
          entry.normalizedTag == normalizedTag &&
          entry.normalizedCity == normalizedCity,
    );
    final now = DateTime.now();
    final targetLabel = (label ?? '').trim().isNotEmpty ? label!.trim() : _defaultLabelForCurrent(trimmed);

    if (existingIndex != -1) {
      final updated = _savedSearches[existingIndex].copyWith(label: targetLabel, savedAt: now);
      _savedSearches[existingIndex] = updated;
      _sortSavedSearches();
      notifyListeners();
      return SavedSearchSaveResult(entry: updated, isUpdate: true);
    }

    final entry = SavedSearchEntry(
      id: now.microsecondsSinceEpoch.toString(),
      label: targetLabel,
      query: trimmed,
      tag: _activeTag,
      city: _activeCity,
      savedAt: now,
      normalizedQuery: normalizedQuery,
      normalizedTag: normalizedTag,
      normalizedCity: normalizedCity,
    );
    _savedSearches.insert(0, entry);
    if (_savedSearches.length > 12) {
      _savedSearches.removeRange(12, _savedSearches.length);
    }
    _sortSavedSearches();
    notifyListeners();
    return SavedSearchSaveResult(entry: entry, isUpdate: false);
  }

  bool renameSavedSearch(String id, String label) {
    final trimmed = label.trim();
    if (trimmed.isEmpty) {
      return false;
    }
    final index = _savedSearches.indexWhere((entry) => entry.id == id);
    if (index == -1) {
      return false;
    }
    final updated = _savedSearches[index].copyWith(label: trimmed, savedAt: DateTime.now());
    _savedSearches[index] = updated;
    _sortSavedSearches();
    notifyListeners();
    return true;
  }

  bool deleteSavedSearch(String id) {
    final before = _savedSearches.length;
    _savedSearches.removeWhere((entry) => entry.id == id);
    if (before == _savedSearches.length) {
      return false;
    }
    notifyListeners();
    return true;
  }

  void applySavedSearch(String id) {
    final entry = _savedSearches.firstWhere(
      (candidate) => candidate.id == id,
      orElse: () => SavedSearchEntry.empty(),
    );
    if (entry.id.isEmpty) {
      return;
    }
    _debounce?.cancel();
    _query = entry.query;
    _activeTag = entry.tag;
    _activeTagNormalized = entry.normalizedTag;
    _activeCity = entry.city;
    _activeCityNormalized = entry.normalizedCity;

    final trimmed = _query.trim();
    if (trimmed.isEmpty) {
      _isLoading = false;
      _setMatches(_allProperties);
    } else {
      final normalizedQuery = entry.normalizedQuery;
      if (normalizedQuery.isEmpty) {
        _setMatches(_allProperties);
      } else {
        final results = _indexed
            .where((candidate) => candidate.index.contains(normalizedQuery))
            .map((candidate) => candidate.property)
            .toList();
        _setMatches(results);
      }
      _isLoading = false;
    }

    if (trimmed.isNotEmpty) {
      final normalized = entry.normalizedQuery;
      final existingIndex = _recent.indexWhere((value) => normalizeText(value) == normalized);
      if (existingIndex != -1) {
        _recent.removeAt(existingIndex);
      }
      _recent.insert(0, entry.query);
      if (_recent.length > 6) {
        _recent.removeLast();
      }
    }

    notifyListeners();
  }

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
    _savedSearches.clear();
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

  String _defaultLabelForCurrent(String trimmedQuery) {
    if (trimmedQuery.isNotEmpty) {
      return trimmedQuery.length > 32 ? '${trimmedQuery.substring(0, 32)}…' : trimmedQuery;
    }
    final parts = <String>[];
    if (_activeCity != null && _activeCity!.isNotEmpty) {
      parts.add(_activeCity!);
    }
    if (_activeTag != null && _activeTag!.isNotEmpty) {
      parts.add('#${_activeTag!}');
    }
    if (parts.isEmpty) {
      return _defaultSavedLabel;
    }
    return parts.join(' • ');
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

  void _sortSavedSearches() {
    _savedSearches.sort((a, b) => b.savedAt.compareTo(a.savedAt));
  }

  static List<SavedSearchEntry> _decodeSaved(List<String>? initialSaved) {
    if (initialSaved == null || initialSaved.isEmpty) {
      return <SavedSearchEntry>[];
    }
    final entries = <SavedSearchEntry>[];
    for (final raw in initialSaved) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          entries.add(SavedSearchEntry.fromJson(decoded));
        }
      } catch (_) {
        // Ignore malformed entries.
      }
    }
    entries.sort((a, b) => b.savedAt.compareTo(a.savedAt));
    return entries;
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

class SavedSearchEntry {
  const SavedSearchEntry({
    required this.id,
    required this.label,
    required this.query,
    this.tag,
    this.city,
    required this.savedAt,
    required this.normalizedQuery,
    this.normalizedTag,
    this.normalizedCity,
  });

  const SavedSearchEntry._empty()
      : id = '',
        label = '',
        query = '',
        tag = null,
        city = null,
        savedAt = DateTime.fromMillisecondsSinceEpoch(0),
        normalizedQuery = '',
        normalizedTag = null,
        normalizedCity = null;

  final String id;
  final String label;
  final String query;
  final String? tag;
  final String? city;
  final DateTime savedAt;
  final String normalizedQuery;
  final String? normalizedTag;
  final String? normalizedCity;

  static SavedSearchEntry empty() => const SavedSearchEntry._empty();

  SavedSearchEntry copyWith({String? label, DateTime? savedAt}) => SavedSearchEntry(
        id: id,
        label: label ?? this.label,
        query: query,
        tag: tag,
        city: city,
        savedAt: savedAt ?? this.savedAt,
        normalizedQuery: normalizedQuery,
        normalizedTag: normalizedTag,
        normalizedCity: normalizedCity,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'query': query,
        'tag': tag,
        'city': city,
        'savedAt': savedAt.millisecondsSinceEpoch,
      };

  String toStorageString() => jsonEncode(toJson());

  static SavedSearchEntry fromJson(Map<String, dynamic> json) {
    final query = (json['query'] as String?) ?? '';
    final tag = json['tag'] as String?;
    final city = json['city'] as String?;
    final savedAtRaw = json['savedAt'];
    DateTime savedAt;
    if (savedAtRaw is int) {
      savedAt = DateTime.fromMillisecondsSinceEpoch(savedAtRaw, isUtc: false);
    } else if (savedAtRaw is String) {
      savedAt = DateTime.tryParse(savedAtRaw) ?? DateTime.now();
    } else {
      savedAt = DateTime.now();
    }
    return SavedSearchEntry(
      id: (json['id'] as String?) ?? DateTime.now().microsecondsSinceEpoch.toString(),
      label: (json['label'] as String?)?.trim().isNotEmpty == true
          ? (json['label'] as String).trim()
          : _fallbackLabel(query, tag, city),
      query: query,
      tag: tag,
      city: city,
      savedAt: savedAt,
      normalizedQuery: normalizeText(query),
      normalizedTag: tag != null ? normalizeText(tag) : null,
      normalizedCity: city != null ? normalizeText(city) : null,
    );
  }

  static String _fallbackLabel(String query, String? tag, String? city) {
    final trimmed = query.trim();
    if (trimmed.isNotEmpty) {
      return trimmed.length > 32 ? '${trimmed.substring(0, 32)}…' : trimmed;
    }
    final parts = <String>[];
    if (city != null && city.isNotEmpty) {
      parts.add(city);
    }
    if (tag != null && tag.isNotEmpty) {
      parts.add('#$tag');
    }
    if (parts.isEmpty) {
      return _defaultSavedLabel;
    }
    return parts.join(' • ');
  }
}

class SavedSearchSaveResult {
  const SavedSearchSaveResult({required this.entry, required this.isUpdate});

  final SavedSearchEntry? entry;
  final bool isUpdate;
}
