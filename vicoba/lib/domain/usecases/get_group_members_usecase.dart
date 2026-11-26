import '../entities/group_member_entity.dart';
import '../repositories/group_repository.dart';

class GetGroupMembersUseCase {
  final GroupRepository _groupRepository;

  GetGroupMembersUseCase(this._groupRepository);

  Future<List<GroupMemberEntity>> execute(String groupId) {
    return _groupRepository.getGroupMembers(groupId);
  }
}
