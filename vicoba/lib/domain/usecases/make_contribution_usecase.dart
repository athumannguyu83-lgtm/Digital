import '../repositories/contribution_repository.dart';

class MakeContributionUseCase {
  final ContributionRepository _contributionRepository;

  MakeContributionUseCase(this._contributionRepository);

  Future<void> execute({
    required String groupId,
    required double amount,
    required String paymentMethod,
  }) async {
    await _contributionRepository.makeContribution(
      groupId: groupId,
      amount: amount,
      paymentMethod: paymentMethod,
    );
  }
}