import 'dart:async';

import 'package:flutter/material.dart';

import '../../../data/models/property.dart';
import '../../../data/mocks/mock_data.dart';

enum CatalogSort { recommended, priceLowToHigh, priceHighToLow, areaHighToLow }

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
  CatalogNotifier({CatalogSort initialSort = CatalogSort.recommended, bool initialListMode = true}) {
    _all = List<Property>.from(MockData.properties);
    sort = initialSort;
    listMode = initialListMode;
    _applyPage(1);
  }

  late List<Property> _all;
  late List<Property> _visible;
  CatalogFilters filters = CatalogFilters();
  late CatalogSort sort;
  late bool listMode;
  int _currentPage = 1;
  final int _pageSize = 6;
  bool _isLoading = false;

  List<Property> get visible => _visible;
  bool get isLoading => _isLoading;
  int get currentPage => _currentPage;
  int get totalPages => (_filtered.length / _pageSize).ceil().clamp(1, 999);

  List<Property> get _filtered {
    final filtered = _all.where((property) {
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
    return _applySort(filtered);
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

  void updateSort(CatalogSort newSort) {
    if (sort == newSort) return;
    sort = newSort;
    _applyPage(1);
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
    sort = CatalogSort.recommended;
    _isLoading = false;
    _applyPage(1);
    notifyListeners();
  }

  int get activeFiltersCount {
    var count = filters.tags.length;
    if (filters.city != null) count += 1;
    if (filters.minBeds != null) count += 1;
    if (filters.minBaths != null) count += 1;
    if (filters.minArea != null) count += 1;
    if (filters.maxPrice != null) count += 1;
    return count;
  }

  List<Property> _applySort(List<Property> items) {
    if (sort == CatalogSort.recommended) {
      return items;
    }
    final sorted = List<Property>.from(items);
    switch (sort) {
      case CatalogSort.priceLowToHigh:
        sorted.sort((a, b) => a.price.compareTo(b.price));
        break;
      case CatalogSort.priceHighToLow:
        sorted.sort((a, b) => b.price.compareTo(a.price));
        break;
      case CatalogSort.areaHighToLow:
        sorted.sort((a, b) => b.area.compareTo(a.area));
        break;
      case CatalogSort.recommended:
        break;
    }
    return sorted;
  }
}
