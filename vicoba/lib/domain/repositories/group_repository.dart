import '../entities/group_entity.dart';

abstract class GroupRepository {
  Stream<List<GroupEntity>> getUserGroups();
  Future<GroupEntity?> getGroupByCode(String code);
  Future<String> createGroup({
    required String name,
    required double contributionAmount,
    required String contributionFrequency,
  });
  Future<void> joinGroup(String groupId);
  Future<bool> isGroupMember(String groupId, String userId);
}
