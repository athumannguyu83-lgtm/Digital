import '../repositories/share_repository.dart';

class BuySharesUseCase {
  final ShareRepository _shareRepository;

  BuySharesUseCase(this._shareRepository);

  Future<void> execute({
    required String groupId,
    required int quantity,
    String paymentMethod = 'M-Pesa',
  }) {
    return _shareRepository.buyShares(
      groupId: groupId,
      quantity: quantity,
      paymentMethod: paymentMethod,
    );
  }
}
