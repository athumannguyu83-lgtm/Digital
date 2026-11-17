import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUserUseCase {
  final AuthRepository _authRepository;

  RegisterUserUseCase(this._authRepository);

  Future<UserEntity> execute({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    return await _authRepository.register(
      name: name,
      email: email,
      password: password,
      phone: phone,
    );
  }
}