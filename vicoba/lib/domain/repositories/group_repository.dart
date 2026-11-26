import '../entities/group_entity.dart';
import '../entities/group_member_entity.dart';
import '../entities/join_request_entity.dart';

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
  Stream<GroupEntity?> watchGroup(String groupId);
  Stream<String?> watchMyJoinRequestStatus(String groupId);
  Future<String> requestToJoin(String groupId);
  Stream<List<JoinRequestEntity>> watchPendingJoinRequests(String groupId);
  Future<void> approveJoinRequest(String groupId, String userId);
  Future<void> rejectJoinRequest(String groupId, String userId);
  Future<List<GroupMemberEntity>> getGroupMembers(String groupId);
}
