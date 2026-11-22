import '../entities/group_entity.dart';
import '../repositories/group_repository.dart';

class JoinGroupByCodeUseCase {
  final GroupRepository _groupRepository;

  JoinGroupByCodeUseCase(this._groupRepository);

  /// Returns the joined group, or null if no group matches the code.
  Future<GroupEntity?> execute(String code) async {
    final group = await _groupRepository.getGroupByCode(code);
    if (group == null) return null;
    await _groupRepository.joinGroup(group.id);
    return group;
  }
}
