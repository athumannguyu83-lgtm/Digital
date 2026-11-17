import '../entities/contribution_entity.dart';
import '../repositories/contribution_repository.dart';

class GetContributionsByFilterUseCase {
  final ContributionRepository _contributionRepository;

  GetContributionsByFilterUseCase(this._contributionRepository);

  Stream<List<ContributionEntity>> execute({
    String? status,
    String? paymentMethod,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _contributionRepository.getContributionsByFilter(
      status: status,
      paymentMethod: paymentMethod,
      startDate: startDate,
      endDate: endDate,
    );
  }
}