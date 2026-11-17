import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/delete_account_usecase.dart';
import '../../../domain/usecases/get_current_user_usecase.dart';
import '../../../domain/usecases/get_profile_photo_usecase.dart';
import '../../../domain/usecases/get_user_role_usecase.dart';
import '../../../domain/usecases/login_user_usecase.dart';
import '../../../domain/usecases/logout_usecase.dart';
import '../../../domain/usecases/register_user_usecase.dart';
import '../../../domain/usecases/send_password_reset_email_usecase.dart';
import '../../../domain/usecases/update_password_usecase.dart';
import '../../../domain/usecases/update_profile_usecase.dart';
import '../../../domain/usecases/upload_profile_photo_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUserUseCase _loginUserUseCase;
  final RegisterUserUseCase _registerUserUseCase;
  final GetUserRoleUseCase _getUserRoleUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final UpdatePasswordUseCase _updatePasswordUseCase;
  final DeleteAccountUseCase _deleteAccountUseCase;
  final UploadProfilePhotoUseCase _uploadProfilePhotoUseCase;
  final SendPasswordResetEmailUseCase _sendPasswordResetEmailUseCase;
  final GetProfilePhotoUseCase _getProfilePhotoUseCase;

  AuthBloc(
    this._loginUserUseCase,
    this._registerUserUseCase,
    this._getUserRoleUseCase,
    this._logoutUseCase,
    this._getCurrentUserUseCase,
    this._updateProfileUseCase,
    this._updatePasswordUseCase,
    this._deleteAccountUseCase,
    this._uploadProfilePhotoUseCase,
    this._sendPasswordResetEmailUseCase,
    this._getProfilePhotoUseCase,
  ) : super(const AuthState()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<FetchUserRoleRequested>(_onFetchUserRoleRequested);
    on<SendPasswordResetRequested>(_onSendPasswordResetRequested);
    on<LoadCurrentUserRequested>(_onLoadCurrentUserRequested);
    on<UpdateProfileRequested>(_onUpdateProfileRequested);
    on<UploadProfilePhotoRequested>(_onUploadProfilePhotoRequested);
    on<LoadProfilePhotoRequested>(_onLoadProfilePhotoRequested);
    on<UpdatePasswordRequested>(_onUpdatePasswordRequested);
    on<DeleteAccountRequested>(_onDeleteAccountRequested);
    on<ClearAuthError>(_onClearAuthError);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AuthStatus.loading,
        operation: AuthOperation.login,
        errorMessage: '',
      ),
    );
    try {
      final user = await _loginUserUseCase.execute(
        email: event.email,
        password: event.password,
      );
      emit(
        state.copyWith(
          status: AuthStatus.success,
          operation: AuthOperation.login,
          currentUser: user,
          errorMessage: '',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          operation: AuthOperation.login,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AuthStatus.loading,
        operation: AuthOperation.register,
        errorMessage: '',
      ),
    );
    try {
      final user = await _registerUserUseCase.execute(
        name: event.name,
        email: event.email,
        password: event.password,
        phone: event.phone,
      );
      emit(
        state.copyWith(
          status: AuthStatus.success,
          operation: AuthOperation.register,
          currentUser: user,
          errorMessage: '',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          operation: AuthOperation.register,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AuthStatus.loading,
        operation: AuthOperation.logout,
        errorMessage: '',
      ),
    );
    try {
      await _logoutUseCase.execute();
      emit(
        state.copyWith(
          status: AuthStatus.success,
          operation: AuthOperation.logout,
          clearCurrentUser: true,
          clearProfilePhoto: true,
          errorMessage: '',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          operation: AuthOperation.logout,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onFetchUserRoleRequested(
    FetchUserRoleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AuthStatus.loading,
        operation: AuthOperation.fetchRole,
        errorMessage: '',
      ),
    );
    try {
      final role = await _getUserRoleUseCase.execute();
      emit(
        state.copyWith(
          status: AuthStatus.success,
          operation: AuthOperation.fetchRole,
          userRole: role,
          errorMessage: '',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          operation: AuthOperation.fetchRole,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onSendPasswordResetRequested(
    SendPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AuthStatus.loading,
        operation: AuthOperation.sendPasswordReset,
        errorMessage: '',
      ),
    );
    try {
      await _sendPasswordResetEmailUseCase.execute(event.email);
      emit(
        state.copyWith(
          status: AuthStatus.success,
          operation: AuthOperation.sendPasswordReset,
          errorMessage: '',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          operation: AuthOperation.sendPasswordReset,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onLoadCurrentUserRequested(
    LoadCurrentUserRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AuthStatus.loading,
        operation: AuthOperation.loadUser,
        errorMessage: '',
      ),
    );
    try {
      final user = await _getCurrentUserUseCase.execute();
      emit(
        state.copyWith(
          status: AuthStatus.success,
          operation: AuthOperation.loadUser,
          currentUser: user,
          errorMessage: '',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          operation: AuthOperation.loadUser,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdateProfileRequested(
    UpdateProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AuthStatus.loading,
        operation: AuthOperation.updateProfile,
        errorMessage: '',
      ),
    );
    try {
      await _updateProfileUseCase.execute(
        name: event.name,
        phone: event.phone,
      );
      final user = await _getCurrentUserUseCase.execute();
      emit(
        state.copyWith(
          status: AuthStatus.success,
          operation: AuthOperation.updateProfile,
          currentUser: user,
          errorMessage: '',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          operation: AuthOperation.updateProfile,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onUploadProfilePhotoRequested(
    UploadProfilePhotoRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AuthStatus.loading,
        operation: AuthOperation.uploadPhoto,
        errorMessage: '',
      ),
    );
    try {
      await _uploadProfilePhotoUseCase.execute(
        event.imageBytes,
        contentType: event.contentType,
        onProgress: event.onProgress,
      );
      final user = await _getCurrentUserUseCase.execute();
      emit(
        state.copyWith(
          status: AuthStatus.success,
          operation: AuthOperation.uploadPhoto,
          currentUser: user,
          errorMessage: '',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          operation: AuthOperation.uploadPhoto,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onLoadProfilePhotoRequested(
    LoadProfilePhotoRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AuthStatus.loading,
        operation: AuthOperation.loadPhoto,
        errorMessage: '',
      ),
    );
    try {
      final bytes = await _getProfilePhotoUseCase.execute(
        event.storageReference,
      );
      emit(
        state.copyWith(
          status: AuthStatus.success,
          operation: AuthOperation.loadPhoto,
          profilePhotoBytes: bytes,
          errorMessage: '',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          operation: AuthOperation.loadPhoto,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdatePasswordRequested(
    UpdatePasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AuthStatus.loading,
        operation: AuthOperation.updatePassword,
        errorMessage: '',
      ),
    );
    try {
      await _updatePasswordUseCase.execute(
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
      );
      emit(
        state.copyWith(
          status: AuthStatus.success,
          operation: AuthOperation.updatePassword,
          errorMessage: '',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          operation: AuthOperation.updatePassword,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDeleteAccountRequested(
    DeleteAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AuthStatus.loading,
        operation: AuthOperation.deleteAccount,
        errorMessage: '',
      ),
    );
    try {
      await _deleteAccountUseCase.execute();
      emit(
        state.copyWith(
          status: AuthStatus.success,
          operation: AuthOperation.deleteAccount,
          clearCurrentUser: true,
          clearProfilePhoto: true,
          errorMessage: '',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          operation: AuthOperation.deleteAccount,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onClearAuthError(ClearAuthError event, Emitter<AuthState> emit) {
    emit(
      state.copyWith(
        status: AuthStatus.initial,
        operation: AuthOperation.none,
        errorMessage: '',
      ),
    );
  }
}
