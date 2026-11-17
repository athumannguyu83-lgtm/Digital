class LoanEntity {
  final String? id;
  final String userId;
  final double amount;
  final String purpose;
  final String duration;
  final double interestRate;
  final String status;
  final DateTime createdAt;

  LoanEntity({
    this.id,
    required this.userId,
    required this.amount,
    required this.purpose,
    required this.duration,
    required this.interestRate,
    required this.status,
    required this.createdAt,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LoanEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}