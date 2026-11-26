class GroupMemberEntity {
  final String id;
  final String name;
  final bool isOwner;

  const GroupMemberEntity({
    required this.id,
    required this.name,
    this.isOwner = false,
  });
}
