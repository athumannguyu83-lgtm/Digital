import '../repositories/group_repository.dart';

class JoinGroupUseCase {
  final GroupRepository _groupRepository;

  JoinGroupUseCase(this._groupRepository);

  Future<void> execute(String groupId) {
    return _groupRepository.joinGroup(groupId);
  }
}
