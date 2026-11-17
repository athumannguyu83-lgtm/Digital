import '../repositories/auth_repository.dart';

class UpdateProfileUseCase {
  final AuthRepository _authRepository;

  UpdateProfileUseCase(this._authRepository);

  Future<void> execute({
    required String name,
    required String phone,
  }) async {
    await _authRepository.updateProfile(
      name: name,
      phone: phone,
    );
  }
}