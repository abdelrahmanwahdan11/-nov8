import 'package:flutter/material.dart';

class PropertyFacilities {
  PropertyFacilities({
    required this.beds,
    required this.baths,
    required this.area,
    required this.parking,
    required this.garden,
  });

  final int beds;
  final int baths;
  final int area;
  final int parking;
  final int garden;
}

class Property {
  Property({
    required this.id,
    required this.title,
    required this.price,
    required this.mortgageEligible,
    required this.images,
    required this.spinFrames,
    required this.address,
    required this.city,
    required this.area,
    required this.description,
    required this.facilities,
    required this.tags,
    required this.rating,
  });

  final String id;
  final String title;
  final int price;
  final bool mortgageEligible;
  final List<String> images;
  final List<String> spinFrames;
  final String address;
  final String city;
  final int area;
  final String description;
  final PropertyFacilities facilities;
  final List<String> tags;
  final double rating;

  Color dynamicAccent() {
    if (tags.contains('modern')) {
      return const Color(0xFFFF8A00);
    }
    if (tags.contains('ivory')) {
      return const Color(0xFFFFD400);
    }
    return const Color(0xFF4FB3FF);
  }
}
