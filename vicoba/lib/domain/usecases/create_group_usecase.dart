import '../repositories/group_repository.dart';

class CreateGroupUseCase {
  final GroupRepository _groupRepository;

  CreateGroupUseCase(this._groupRepository);

  Future<String> execute({
    required String name,
    required double contributionAmount,
    required String contributionFrequency,
    double? sharePrice,
    int maxSharesPerPurchase = 1000,
    double loanMultiplier = 3.0,
  }) {
    return _groupRepository.createGroup(
      name: name,
      contributionAmount: contributionAmount,
      contributionFrequency: contributionFrequency,
      sharePrice: sharePrice,
      maxSharesPerPurchase: maxSharesPerPurchase,
      loanMultiplier: loanMultiplier,
    );
  }
}
