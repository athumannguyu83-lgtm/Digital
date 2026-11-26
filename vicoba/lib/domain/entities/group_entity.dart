class GroupEntity {
  final String id;
  final String name;
  final double contributionAmount;
  final String contributionFrequency;
  final String? groupCode;
  final List<String> members;
  final int memberCount;
  final String? ownerId;

  const GroupEntity({
    required this.id,
    required this.name,
    required this.contributionAmount,
    required this.contributionFrequency,
    this.groupCode,
    this.members = const [],
    this.memberCount = 0,
    this.ownerId,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GroupEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
