import '../entities/share_entity.dart';

abstract class ShareRepository {
  Stream<List<ShareEntity>> getMyShares();
  Future<void> buyShares({
    required String groupId,
    required int quantity,
    String paymentMethod = 'M-Pesa',
  });
  Future<void> redeemShares({
    required String groupId,
    required int quantity,
    String paymentMethod = 'M-Pesa',
  });
  Future<void> updateShareStatus(String shareId, String status);
  Future<double> getShareCapital(String groupId);
  Stream<double> watchShareCapital(String groupId);
}
