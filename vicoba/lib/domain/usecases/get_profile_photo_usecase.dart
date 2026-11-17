import 'dart:typed_data';

import '../repositories/auth_repository.dart';

class GetProfilePhotoUseCase {
  final AuthRepository _authRepository;

  GetProfilePhotoUseCase(this._authRepository);

  Future<Uint8List?> execute(String storageReference) {
    return _authRepository.getProfilePhoto(storageReference);
  }
}
