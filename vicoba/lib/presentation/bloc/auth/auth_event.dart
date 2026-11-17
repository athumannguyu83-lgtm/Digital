import 'dart:typed_data';

import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String phone;

  const RegisterRequested({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
  });

  @override
  List<Object?> get props => [name, email, password, phone];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

class FetchUserRoleRequested extends AuthEvent {
  const FetchUserRoleRequested();
}

class SendPasswordResetRequested extends AuthEvent {
  final String email;

  const SendPasswordResetRequested(this.email);

  @override
  List<Object?> get props => [email];
}

class LoadCurrentUserRequested extends AuthEvent {
  const LoadCurrentUserRequested();
}

class UpdateProfileRequested extends AuthEvent {
  final String name;
  final String phone;

  const UpdateProfileRequested({required this.name, required this.phone});

  @override
  List<Object?> get props => [name, phone];
}

class UploadProfilePhotoRequested extends AuthEvent {
  final Uint8List imageBytes;
  final String contentType;
  final void Function(double progress)? onProgress;

  const UploadProfilePhotoRequested(
    this.imageBytes, {
    required this.contentType,
    this.onProgress,
  });

  @override
  List<Object?> get props => [imageBytes, contentType];
}

class LoadProfilePhotoRequested extends AuthEvent {
  final String storageReference;

  const LoadProfilePhotoRequested(this.storageReference);

  @override
  List<Object?> get props => [storageReference];
}

class UpdatePasswordRequested extends AuthEvent {
  final String currentPassword;
  final String newPassword;

  const UpdatePasswordRequested({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];
}

class DeleteAccountRequested extends AuthEvent {
  const DeleteAccountRequested();
}

class ClearAuthError extends AuthEvent {
  const ClearAuthError();
}
