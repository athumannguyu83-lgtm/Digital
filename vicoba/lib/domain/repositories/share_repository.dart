import '../entities/share_entity.dart';

abstract class ShareRepository {
  Stream<List<ShareEntity>> getMyShares();
  Future<void> buyShares({
    required String groupId,
    required int quantity,
  });
  Future<double> getShareCapital(String groupId);
}
