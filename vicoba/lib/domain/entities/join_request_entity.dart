class JoinRequestEntity {
  final String userId;
  final String userName;

  /// One of: pending, approved, rejected.
  final String status;
  final DateTime? createdAt;

  const JoinRequestEntity({
    required this.userId,
    required this.userName,
    required this.status,
    this.createdAt,
  });
}
