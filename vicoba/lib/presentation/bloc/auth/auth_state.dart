import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import '../../../domain/entities/user_entity.dart';

enum AuthStatus { initial, loading, success, failure }

enum AuthOperation {
  none,
  login,
  register,
  logout,
  fetchRole,
  sendPasswordReset,
  loadUser,
  updateProfile,
  uploadPhoto,
  loadPhoto,
  updatePassword,
  deleteAccount,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final AuthOperation operation;
  final String errorMessage;
  final UserEntity? currentUser;
  final String userRole;
  final Uint8List? profilePhotoBytes;

  const AuthState({
    this.status = AuthStatus.initial,
    this.operation = AuthOperation.none,
    this.errorMessage = '',
    this.currentUser,
    this.userRole = 'member',
    this.profilePhotoBytes,
  });

  bool get isLoading => status == AuthStatus.loading;

  AuthState copyWith({
    AuthStatus? status,
    AuthOperation? operation,
    String? errorMessage,
    UserEntity? currentUser,
    bool clearCurrentUser = false,
    String? userRole,
    Uint8List? profilePhotoBytes,
    bool clearProfilePhoto = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      operation: operation ?? this.operation,
      errorMessage: errorMessage ?? this.errorMessage,
      currentUser: clearCurrentUser ? null : (currentUser ?? this.currentUser),
      userRole: userRole ?? this.userRole,
      profilePhotoBytes: clearProfilePhoto
          ? null
          : (profilePhotoBytes ?? this.profilePhotoBytes),
    );
  }

  @override
  List<Object?> get props => [
    status,
    operation,
    errorMessage,
    currentUser,
    userRole,
    profilePhotoBytes,
  ];
}
