import '../../domain/entities/group_entity.dart';
import '../../domain/entities/group_member_entity.dart';
import '../../domain/entities/join_request_entity.dart';
import '../../domain/repositories/group_repository.dart';
import '../datasources/firebase_group_datasource.dart';

class GroupRepositoryImpl implements GroupRepository {
  final FirebaseGroupDataSource _groupDataSource;

  GroupRepositoryImpl(this._groupDataSource);

  @override
  Stream<List<GroupEntity>> getUserGroups() {
    return _groupDataSource.getUserGroups().map(
          (models) => models.map((model) => model.toEntity()).toList(),
        );
  }

  @override
  Future<GroupEntity?> getGroupByCode(String code) async {
    final model = await _groupDataSource.getGroupByCode(code);
    return model?.toEntity();
  }

  @override
  Future<String> createGroup({
    required String name,
    required double contributionAmount,
    required String contributionFrequency,
    double? sharePrice,
    int maxSharesPerPurchase = 1000,
    double loanMultiplier = 3.0,
  }) {
    return _groupDataSource.createGroup(
      name: name,
      contributionAmount: contributionAmount,
      contributionFrequency: contributionFrequency,
      sharePrice: sharePrice,
      maxSharesPerPurchase: maxSharesPerPurchase,
      loanMultiplier: loanMultiplier,
    );
  }

  @override
  Future<void> joinGroup(String groupId) {
    return _groupDataSource.joinGroup(groupId);
  }

  @override
  Future<bool> isGroupMember(String groupId, String userId) {
    return _groupDataSource.isGroupMember(groupId, userId);
  }

  @override
  Stream<GroupEntity?> watchGroup(String groupId) {
    return _groupDataSource.watchGroup(groupId).map((m) => m?.toEntity());
  }

  @override
  Stream<String?> watchMyJoinRequestStatus(String groupId) {
    return _groupDataSource.watchMyJoinRequestStatus(groupId);
  }

  @override
  Future<String> requestToJoin(String groupId) {
    return _groupDataSource.requestToJoin(groupId);
  }

  @override
  Stream<List<JoinRequestEntity>> watchPendingJoinRequests(String groupId) {
    return _groupDataSource.watchPendingJoinRequests(groupId);
  }

  @override
  Future<void> approveJoinRequest(String groupId, String userId) {
    return _groupDataSource.approveJoinRequest(groupId, userId);
  }

  @override
  Future<void> rejectJoinRequest(String groupId, String userId) {
    return _groupDataSource.rejectJoinRequest(groupId, userId);
  }

  @override
  Future<List<GroupMemberEntity>> getGroupMembers(String groupId) {
    return _groupDataSource.getGroupMembers(groupId);
  }
}
