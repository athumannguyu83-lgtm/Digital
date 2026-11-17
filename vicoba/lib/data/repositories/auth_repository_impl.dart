import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _authDataSource;

  AuthRepositoryImpl(this._authDataSource);

  @override
  Future<UserEntity> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    final cred = await _authDataSource.registerWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _authDataSource.createUserDocument(
      uid: cred.user!.uid,
      userData: {
        "name": name,
        "email": email,
        "phone": phone,
        "role": "member",
        "createdAt": Timestamp.now(),
      },
    );

    return UserEntity(
      id: cred.user!.uid,
      name: name,
      email: email,
      phone: phone,
      role: "member",
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    final cred = await _authDataSource.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final doc = await _authDataSource.getUserDocument(cred.user!.uid);
    final userModel = UserModel.fromMap(
      doc.data() as Map<String, dynamic>,
      doc.id,
    );

    return userModel.toEntity();
  }

  @override
  Future<String> getUserRole() async {
    final uid = _authDataSource.getCurrentUserId();
    if (uid == null) {
      throw Exception("User not logged in");
    }

    final doc = await _authDataSource.getUserDocument(uid);
    return doc["role"];
  }

  @override
  Future<void> logout() async {
    await _authDataSource.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _authDataSource.sendPasswordResetEmail(email);
  }

  @override
  Future<UserEntity> getCurrentUser() async {
    final uid = _authDataSource.getCurrentUserId();
    if (uid == null) {
      throw Exception("User not logged in");
    }

    final doc = await _authDataSource.getUserDocument(uid);
    final userModel = UserModel.fromMap(
      doc.data() as Map<String, dynamic>,
      doc.id,
    );

    return userModel.toEntity();
  }

  @override
  Future<void> updateProfile({
    required String name,
    required String phone,
  }) async {
    final uid = _authDataSource.getCurrentUserId();
    if (uid == null) {
      throw Exception("User not logged in");
    }

    await _authDataSource.updateUserDocument(
      uid: uid,
      userData: {"name": name, "phone": phone},
    );
  }

  @override
  Future<String> uploadProfilePhoto(
    Uint8List imageBytes, {
    required String contentType,
    void Function(double progress)? onProgress,
  }) async {
    final uid = _authDataSource.getCurrentUserId();
    if (uid == null) {
      throw Exception("User not logged in");
    }

    final imagePath = await _authDataSource.uploadProfilePhoto(
      uid,
      imageBytes,
      contentType: contentType,
      onProgress: onProgress,
    );
    await _authDataSource.updateUserDocument(
      uid: uid,
      userData: {
        "profileImagePath": imagePath,
        "profileImageUrl": FieldValue.delete(),
      },
    );
    return imagePath;
  }

  @override
  Future<Uint8List?> getProfilePhoto(String storageReference) {
    return _authDataSource.getProfilePhoto(storageReference);
  }

  @override
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _authDataSource.getCurrentUser();
    if (user == null) {
      throw Exception("User not logged in");
    }

    // Re-authenticate user with current password
    final credential = await _authDataSource.signInWithEmailAndPassword(
      email: user.email!,
      password: currentPassword,
    );

    // Update password
    await credential.user?.updatePassword(newPassword);
  }

  @override
  Future<void> deleteAccount() async {
    final user = _authDataSource.getCurrentUser();
    if (user == null) {
      throw Exception("User not logged in");
    }

    // Delete user document from Firestore
    await _authDataSource.deleteUserDocument(user.uid);

    // Delete user authentication
    await user.delete();
  }
}
