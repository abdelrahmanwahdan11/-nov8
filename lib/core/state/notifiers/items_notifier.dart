import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../data/models/my_item.dart';
import '../../../data/models/offer.dart';
import '../../../data/mocks/mock_data.dart';

class ItemsNotifier extends ChangeNotifier {
  ItemsNotifier({List<MyItem>? items, List<Offer>? offers})
      : _myItems = items ?? List<MyItem>.from(MockData.myItems),
        _offers = offers ?? List<Offer>.from(MockData.offers);

  final List<MyItem> _myItems;
  final List<Offer> _offers;

  List<MyItem> get myItems => List.unmodifiable(_myItems);
  List<Offer> get offers => List.unmodifiable(_offers);

  void add(MyItem item) {
    _myItems.add(item);
    notifyListeners();
  }

  void remove(String id) {
    _myItems.removeWhere((element) => element.id == id);
    notifyListeners();
  }

  void update(MyItem item) {
    final index = _myItems.indexWhere((element) => element.id == item.id);
    if (index != -1) {
      _myItems[index] = item;
      notifyListeners();
    }
  }

  String toJson() {
    final data = _myItems
        .map((item) => {
              'id': item.id,
              'title': item.title,
              'photos': item.photos,
              'specs': {
                'condition': item.specs.condition,
                'brand': item.specs.brand,
                'year': item.specs.year,
                'notes': item.specs.notes,
              },
              'forSale': item.forSale,
              'wantedPrice': item.wantedPrice,
              'tips': item.tips,
              'status': item.status,
            })
        .toList();
    return jsonEncode(data);
  }

  static List<MyItem> fromJson(String? json) {
    if (json == null || json.isEmpty) {
      return List<MyItem>.from(MockData.myItems);
    }
    try {
      final decoded = jsonDecode(json) as List<dynamic>;
      return decoded
          .map((e) {
            final map = Map<String, dynamic>.from(e as Map);
            final specs = Map<String, dynamic>.from(map['specs'] as Map);
            return MyItem(
              id: map['id'] as String,
              title: map['title'] as String,
              photos: List<String>.from(map['photos'] as List),
              specs: MyItemSpecs(
                condition: specs['condition'] as String,
                brand: specs['brand'] as String,
                year: (specs['year'] as num).toInt(),
                notes: specs['notes'] as String,
              ),
              forSale: map['forSale'] as bool,
              wantedPrice: (map['wantedPrice'] as num?)?.toDouble(),
              tips: List<String>.from(map['tips'] as List),
              status: map['status'] as String,
            );
          })
          .toList();
    } catch (_) {
      return List<MyItem>.from(MockData.myItems);
    }
  }

  void reset() {
    _myItems
      ..clear()
      ..addAll(MockData.myItems);
    _offers
      ..clear()
      ..addAll(MockData.offers);
    notifyListeners();
  }
}
