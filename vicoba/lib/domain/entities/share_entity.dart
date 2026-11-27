class ShareEntity {
  final String? id;
  final String userId;
  final String groupId;
  final int quantity;
  final double unitPrice;
  final double totalAmount;
  final DateTime createdAt;

  const ShareEntity({
    this.id,
    required this.userId,
    required this.groupId,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
    required this.createdAt,
  });

  double get shareValue => quantity * unitPrice;
}
