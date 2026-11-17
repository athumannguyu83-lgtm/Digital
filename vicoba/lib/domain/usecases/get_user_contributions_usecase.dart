import '../entities/contribution_entity.dart';
import '../repositories/contribution_repository.dart';

class GetUserContributionsUseCase {
  final ContributionRepository _contributionRepository;

  GetUserContributionsUseCase(this._contributionRepository);

  Stream<List<ContributionEntity>> execute() {
    return _contributionRepository.getUserContributions();
  }
}