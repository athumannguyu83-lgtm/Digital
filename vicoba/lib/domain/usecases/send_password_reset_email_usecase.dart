import '../repositories/auth_repository.dart';

class SendPasswordResetEmailUseCase {
  final AuthRepository _authRepository;

  SendPasswordResetEmailUseCase(this._authRepository);

  Future<void> execute(String email) {
    return _authRepository.sendPasswordResetEmail(email);
  }
}
