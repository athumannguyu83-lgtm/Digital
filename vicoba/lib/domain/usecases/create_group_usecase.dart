import '../repositories/group_repository.dart';

class CreateGroupUseCase {
  final GroupRepository _groupRepository;

  CreateGroupUseCase(this._groupRepository);

  Future<String> execute({
    required String name,
    required double contributionAmount,
    required String contributionFrequency,
  }) {
    return _groupRepository.createGroup(
      name: name,
      contributionAmount: contributionAmount,
      contributionFrequency: contributionFrequency,
    );
  }
}
