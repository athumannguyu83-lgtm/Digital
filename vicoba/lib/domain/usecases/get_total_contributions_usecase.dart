import '../repositories/contribution_repository.dart';

class GetTotalContributionsUseCase {
  final ContributionRepository _contributionRepository;

  GetTotalContributionsUseCase(this._contributionRepository);

  Future<double> execute() async {
    return await _contributionRepository.getTotalContributions();
  }
}