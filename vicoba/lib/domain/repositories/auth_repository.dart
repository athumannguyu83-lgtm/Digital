import 'dart:typed_data';

import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  });

  Future<UserEntity> login({required String email, required String password});

  Future<String> getUserRole();
  Future<void> logout();
  Future<void> sendPasswordResetEmail(String email);

  // Profile management methods
  Future<UserEntity> getCurrentUser();
  Future<void> updateProfile({required String name, required String phone});
  Future<String> uploadProfilePhoto(
    Uint8List imageBytes, {
    required String contentType,
    void Function(double progress)? onProgress,
  });
  Future<Uint8List?> getProfilePhoto(String storageReference);
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  });
  Future<void> deleteAccount();
}
