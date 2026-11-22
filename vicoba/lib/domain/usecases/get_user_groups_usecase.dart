import '../entities/group_entity.dart';
import '../repositories/group_repository.dart';

class GetUserGroupsUseCase {
  final GroupRepository _groupRepository;

  GetUserGroupsUseCase(this._groupRepository);

  Stream<List<GroupEntity>> execute() {
    return _groupRepository.getUserGroups();
  }
}
