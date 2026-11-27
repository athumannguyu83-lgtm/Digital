import '../repositories/share_repository.dart';

class GetShareCapitalUseCase {
  final ShareRepository _shareRepository;

  GetShareCapitalUseCase(this._shareRepository);

  Future<double> execute(String groupId) {
    return _shareRepository.getShareCapital(groupId);
  }
}
