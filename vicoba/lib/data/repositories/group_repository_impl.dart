import '../../domain/entities/group_entity.dart';
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
  }) {
    return _groupDataSource.createGroup(
      name: name,
      contributionAmount: contributionAmount,
      contributionFrequency: contributionFrequency,
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
}
