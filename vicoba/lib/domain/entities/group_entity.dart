class GroupEntity {
  final String id;
  final String name;
  final double contributionAmount;
  final String contributionFrequency;
  final double? sharePrice;
  final int maxSharesPerPurchase;
  final double loanMultiplier;
  final String? groupCode;
  final List<String> members;
  final int memberCount;
  final String? ownerId;

  const GroupEntity({
    required this.id,
    required this.name,
    required this.contributionAmount,
    required this.contributionFrequency,
    this.sharePrice,
    this.maxSharesPerPurchase = 1000,
    this.loanMultiplier = 3.0,
    this.groupCode,
    this.members = const [],
    this.memberCount = 0,
    this.ownerId,
  });

  /// Dedicated share price if configured, falling back to contributionAmount for legacy groups.
  double get effectiveSharePrice =>
      (sharePrice != null && sharePrice! > 0) ? sharePrice! : contributionAmount;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GroupEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
