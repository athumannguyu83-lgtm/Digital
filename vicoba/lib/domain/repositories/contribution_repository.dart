import '../entities/contribution_entity.dart';

abstract class ContributionRepository {
  Future<void> makeContribution({
    required String groupId,
    required double amount,
    required String paymentMethod,
  });

  Stream<List<ContributionEntity>> getUserContributions();
  Stream<List<ContributionEntity>> getGroupContributions(String groupId);
  Stream<List<ContributionEntity>> getContributionsByFilter({
    String? status,
    String? paymentMethod,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<double> getTotalContributions();
  Future<double> getTotalContributionsByGroup(String groupId);
}