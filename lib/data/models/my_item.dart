class MyItemSpecs {
  MyItemSpecs({
    required this.condition,
    required this.brand,
    required this.year,
    required this.notes,
  });

  final String condition;
  final String brand;
  final int year;
  final String notes;
}

class MyItem {
  MyItem({
    required this.id,
    required this.title,
    required this.photos,
    required this.specs,
    required this.forSale,
    this.wantedPrice,
    required this.tips,
    required this.status,
  });

  final String id;
  final String title;
  final List<String> photos;
  final MyItemSpecs specs;
  final bool forSale;
  final double? wantedPrice;
  final List<String> tips;
  final String status;
}
