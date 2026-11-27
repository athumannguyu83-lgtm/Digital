import '../../domain/entities/share_entity.dart';
import '../../domain/repositories/share_repository.dart';
import '../datasources/firebase_share_datasource.dart';

class ShareRepositoryImpl implements ShareRepository {
  final FirebaseShareDataSource _shareDataSource;

  ShareRepositoryImpl(this._shareDataSource);

  @override
  Stream<List<ShareEntity>> getMyShares() {
    return _shareDataSource.getMyShares().map(
          (models) => models.map((model) => model.toEntity()).toList(),
        );
  }

  @override
  Future<void> buyShares({
    required String groupId,
    required int quantity,
    String paymentMethod = 'M-Pesa',
  }) {
    return _shareDataSource.buyShares(
      groupId: groupId,
      quantity: quantity,
      paymentMethod: paymentMethod,
    );
  }

  @override
  Future<void> redeemShares({
    required String groupId,
    required int quantity,
    String paymentMethod = 'M-Pesa',
  }) {
    return _shareDataSource.redeemShares(
      groupId: groupId,
      quantity: quantity,
      paymentMethod: paymentMethod,
    );
  }

  @override
  Future<void> updateShareStatus(String shareId, String status) {
    return _shareDataSource.updateShareStatus(shareId, status);
  }

  @override
  Future<double> getShareCapital(String groupId) {
    return _shareDataSource.getShareCapital(groupId);
  }

  @override
  Stream<double> watchShareCapital(String groupId) {
    return _shareDataSource.watchShareCapital(groupId);
  }
}
