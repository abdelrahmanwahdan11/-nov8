import 'dart:async';

import 'package:flutter/material.dart';

import '../../../data/models/property.dart';
import '../../../data/mocks/mock_data.dart';

class CatalogFilters {
  static const _sentinel = Object();

  CatalogFilters({
    this.tags = const <String>{},
    this.city,
    this.minBeds,
    this.minBaths,
    this.minArea,
    this.maxPrice,
  });

  final Set<String> tags;
  final String? city;
  final int? minBeds;
  final int? minBaths;
  final int? minArea;
  final int? maxPrice;

  CatalogFilters copyWith({
    Set<String>? tags,
    Object? city = _sentinel,
    int? minBeds,
    int? minBaths,
    int? minArea,
    int? maxPrice,
  }) {
    return CatalogFilters(
      tags: tags ?? this.tags,
      city: city == _sentinel ? this.city : city as String?,
      minBeds: minBeds ?? this.minBeds,
      minBaths: minBaths ?? this.minBaths,
      minArea: minArea ?? this.minArea,
      maxPrice: maxPrice ?? this.maxPrice,
    );
  }

  bool get isEmpty =>
      tags.isEmpty &&
      city == null &&
      minBeds == null &&
      minBaths == null &&
      minArea == null &&
      maxPrice == null;
}

class CatalogNotifier extends ChangeNotifier {
  CatalogNotifier() {
    _all = List<Property>.from(MockData.properties);
    _visible = _all.take(_pageSize).toList();
  }

  late List<Property> _all;
  late List<Property> _visible;
  CatalogFilters filters = CatalogFilters();
  int _currentPage = 1;
  final int _pageSize = 6;
  bool _isLoading = false;
  bool listMode = true;

  List<Property> get visible => _visible;
  bool get isLoading => _isLoading;
  int get currentPage => _currentPage;
  int get totalPages => (_filtered.length / _pageSize).ceil().clamp(1, 999);

  List<Property> get _filtered {
    return _all.where((property) {
      if (filters.tags.isNotEmpty && filters.tags.intersection(property.tags.toSet()).isEmpty) {
        return false;
      }
      if (filters.city != null && property.city != filters.city) {
        return false;
      }
      if (filters.minBeds != null && property.facilities.beds < filters.minBeds!) {
        return false;
      }
      if (filters.minBaths != null && property.facilities.baths < filters.minBaths!) {
        return false;
      }
      if (filters.minArea != null && property.area < filters.minArea!) {
        return false;
      }
      if (filters.maxPrice != null && property.price > filters.maxPrice!) {
        return false;
      }
      return true;
    }).toList();
  }

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 750));
    _all = List<Property>.from(MockData.properties);
    _applyPage(1);
    _isLoading = false;
    notifyListeners();
  }

  void toggleViewMode() {
    listMode = !listMode;
    notifyListeners();
  }

  void updateFilters(CatalogFilters newFilters) {
    filters = newFilters;
    _applyPage(1);
    notifyListeners();
  }

  void clearFilters() {
    filters = CatalogFilters();
    _applyPage(1);
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_visible.length >= _filtered.length) return;
    _isLoading = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _currentPage += 1;
    final endIndex = (_currentPage * _pageSize).clamp(0, _filtered.length);
    _visible = _filtered.take(endIndex).toList();
    _isLoading = false;
    notifyListeners();
  }

  void _applyPage(int page) {
    _currentPage = page;
    final filtered = _filtered;
    final endIndex = (_currentPage * _pageSize).clamp(0, filtered.length);
    _visible = filtered.take(endIndex).toList();
  }

  void reset() {
    _all = List<Property>.from(MockData.properties);
    filters = CatalogFilters();
    listMode = true;
    _isLoading = false;
    _applyPage(1);
    notifyListeners();
  }
}
