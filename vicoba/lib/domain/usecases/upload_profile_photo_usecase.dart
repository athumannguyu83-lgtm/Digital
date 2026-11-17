import 'dart:typed_data';

import '../repositories/auth_repository.dart';

class UploadProfilePhotoUseCase {
  final AuthRepository _authRepository;

  UploadProfilePhotoUseCase(this._authRepository);

  Future<String> execute(
    Uint8List imageBytes, {
    required String contentType,
    void Function(double progress)? onProgress,
  }) {
    return _authRepository.uploadProfilePhoto(
      imageBytes,
      contentType: contentType,
      onProgress: onProgress,
    );
  }
}
