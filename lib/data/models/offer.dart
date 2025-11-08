class Offer {
  Offer({
    required this.id,
    required this.itemId,
    required this.amount,
    required this.fromUser,
    required this.message,
    required this.createdAt,
  });

  final String id;
  final String itemId;
  final double amount;
  final String fromUser;
  final String message;
  final DateTime createdAt;
}
