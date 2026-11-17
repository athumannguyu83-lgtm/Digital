class ContributionEntity {
  final String? id;
  final String userId;
  final String groupId;
  final double amount;
  final String paymentMethod;
  final String status;
  final DateTime contributionDate;
  final DateTime createdAt;

  ContributionEntity({
    this.id,
    required this.userId,
    required this.groupId,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    required this.contributionDate,
    required this.createdAt,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ContributionEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}