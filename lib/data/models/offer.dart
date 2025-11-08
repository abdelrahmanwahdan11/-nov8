enum OfferStatus { pending, accepted, declined, countered }

class Offer {
  const Offer({
    required this.id,
    required this.itemId,
    required this.amount,
    required this.fromUser,
    required this.message,
    required this.createdAt,
    this.status = OfferStatus.pending,
    this.counterAmount,
    this.responseNote,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? createdAt;

  final String id;
  final String itemId;
  final double amount;
  final String fromUser;
  final String message;
  final DateTime createdAt;
  final OfferStatus status;
  final double? counterAmount;
  final String? responseNote;
  final DateTime updatedAt;

  Offer copyWith({
    OfferStatus? status,
    double? counterAmount,
    String? responseNote,
    DateTime? updatedAt,
  }) {
    return Offer(
      id: id,
      itemId: itemId,
      amount: amount,
      fromUser: fromUser,
      message: message,
      createdAt: createdAt,
      status: status ?? this.status,
      counterAmount: counterAmount ?? this.counterAmount,
      responseNote: responseNote ?? this.responseNote,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
