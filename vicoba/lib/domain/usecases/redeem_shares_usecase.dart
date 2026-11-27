import '../repositories/share_repository.dart';

class RedeemSharesUseCase {
  final ShareRepository _shareRepository;

  RedeemSharesUseCase(this._shareRepository);

  Future<void> execute({
    required String groupId,
    required int quantity,
    String paymentMethod = 'M-Pesa',
  }) {
    return _shareRepository.redeemShares(
      groupId: groupId,
      quantity: quantity,
      paymentMethod: paymentMethod,
    );
  }
}
