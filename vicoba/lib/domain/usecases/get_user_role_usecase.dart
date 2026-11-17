import '../repositories/auth_repository.dart';

class GetUserRoleUseCase {
  final AuthRepository _authRepository;

  GetUserRoleUseCase(this._authRepository);

  Future<String> execute() async {
    return await _authRepository.getUserRole();
  }
}