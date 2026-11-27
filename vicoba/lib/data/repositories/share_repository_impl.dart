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
  }) {
    return _shareDataSource.buyShares(
      groupId: groupId,
      quantity: quantity,
    );
  }

  @override
  Future<double> getShareCapital(String groupId) {
    return _shareDataSource.getShareCapital(groupId);
  }
}
