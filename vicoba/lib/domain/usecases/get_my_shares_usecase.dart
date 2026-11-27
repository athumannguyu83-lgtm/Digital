import '../entities/share_entity.dart';
import '../repositories/share_repository.dart';

class GetMySharesUseCase {
  final ShareRepository _shareRepository;

  GetMySharesUseCase(this._shareRepository);

  Stream<List<ShareEntity>> execute() {
    return _shareRepository.getMyShares();
  }
}
