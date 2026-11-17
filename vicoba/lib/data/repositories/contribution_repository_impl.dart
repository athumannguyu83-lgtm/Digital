import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/contribution_entity.dart';
import '../../domain/repositories/contribution_repository.dart';
import '../datasources/firebase_contribution_datasource.dart';
import '../models/contribution_model.dart';

class ContributionRepositoryImpl implements ContributionRepository {
  final FirebaseContributionDataSource _contributionDataSource;

  ContributionRepositoryImpl(this._contributionDataSource);

  @override
  Future<void> makeContribution({
    required String groupId,
    required double amount,
    required String paymentMethod,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Future.error("User not logged in");
    }

    final contributionModel = ContributionModel(
      userId: user.uid,
      groupId: groupId,
      amount: amount,
      paymentMethod: paymentMethod,
      status: "pending",
      contributionDate: Timestamp.now(),
      createdAt: Timestamp.now(),
    );

    await _contributionDataSource.addContribution(contributionModel.toMap());
  }

  @override
  Stream<List<ContributionEntity>> getUserContributions() {
    return _contributionDataSource.getUserContributions().map((models) =>
        models.map((model) => model.toEntity()).toList());
  }

  @override
  Stream<List<ContributionEntity>> getGroupContributions(String groupId) {
    return _contributionDataSource.getGroupContributions(groupId).map((models) =>
        models.map((model) => model.toEntity()).toList());
  }

  @override
  Stream<List<ContributionEntity>> getContributionsByFilter({
    String? status,
    String? paymentMethod,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _contributionDataSource.getContributionsByFilter(
      status: status,
      paymentMethod: paymentMethod,
      startDate: startDate,
      endDate: endDate,
    ).map((models) => models.map((model) => model.toEntity()).toList());
  }

  @override
  Future<double> getTotalContributions() async {
    return await _contributionDataSource.getTotalContributions();
  }

  @override
  Future<double> getTotalContributionsByGroup(String groupId) async {
    return await _contributionDataSource.getTotalContributionsByGroup(groupId);
  }
}