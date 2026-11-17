import '../repositories/auth_repository.dart';

class UpdatePasswordUseCase {
  final AuthRepository _authRepository;

  UpdatePasswordUseCase(this._authRepository);

  Future<void> execute({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _authRepository.updatePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}