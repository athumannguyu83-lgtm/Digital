class ShareEntity {
  final String? id;
  final String userId;
  final String groupId;
  final int quantity;
  final double unitPrice;
  final double totalAmount;
  final String paymentMethod;

  /// One of: approved, pending, rejected.
  final String status;

  /// One of: purchase, redemption.
  final String type;
  final DateTime createdAt;

  const ShareEntity({
    this.id,
    required this.userId,
    required this.groupId,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
    this.paymentMethod = 'M-Pesa',
    this.status = 'approved',
    this.type = 'purchase',
    required this.createdAt,
  });

  bool get isRedemption => type.toLowerCase() == 'redemption' || quantity < 0;
  bool get isRejected => status.toLowerCase() == 'rejected';
  bool get isApproved => status.toLowerCase() == 'approved';

  /// Net signed share value (negative for redemptions, 0 if rejected).
  double get shareValue {
    if (isRejected) return 0.0;
    return quantity * unitPrice;
  }

  int get netQuantity => isRejected ? 0 : quantity;
}
