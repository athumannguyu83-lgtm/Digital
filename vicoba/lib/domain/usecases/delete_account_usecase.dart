import '../repositories/auth_repository.dart';

class DeleteAccountUseCase {
  final AuthRepository _authRepository;

  DeleteAccountUseCase(this._authRepository);

  Future<void> execute() async {
    await _authRepository.deleteAccount();
  }
}