import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/loan_entity.dart';
import '../../../domain/usecases/approve_loan_usecase.dart';
import '../../../domain/usecases/get_pending_loans_usecase.dart';
import '../../../domain/usecases/get_user_loans_usecase.dart';
import '../../../domain/usecases/reject_loan_usecase.dart';
import '../../../domain/usecases/submit_loan_usecase.dart';
import 'loan_event.dart';
import 'loan_state.dart';

class LoanBloc extends Bloc<LoanEvent, LoanState> {
  final SubmitLoanUseCase _submitLoanUseCase;
  final GetUserLoansUseCase _getUserLoansUseCase;
  final GetPendingLoansUseCase _getPendingLoansUseCase;
  final ApproveLoanUseCase _approveLoanUseCase;
  final RejectLoanUseCase _rejectLoanUseCase;

  LoanBloc(
    this._submitLoanUseCase,
    this._getUserLoansUseCase,
    this._getPendingLoansUseCase,
    this._approveLoanUseCase,
    this._rejectLoanUseCase,
  ) : super(const LoanState()) {
    on<LoadLoansRequested>(_onLoadLoansRequested);
    on<LoadPendingLoansRequested>(_onLoadPendingLoansRequested);
    on<SubmitLoanRequested>(_onSubmitLoanRequested);
    on<ApproveLoanRequested>(_onApproveLoanRequested);
    on<RejectLoanRequested>(_onRejectLoanRequested);
    on<ClearLoanError>(_onClearLoanError);

    add(const LoadLoansRequested());
    add(const LoadPendingLoansRequested());
  }

  bool get _hasCurrentUser => FirebaseAuth.instance.currentUser != null;

  LoanState _mapUserLoans(List<LoanEntity> loans) {
    final isActionLoading = state.status == LoanStatus.loading;
    return state.copyWith(
      userLoans: loans,
      status: isActionLoading ? state.status : LoanStatus.initial,
      operation: isActionLoading ? state.operation : LoanOperation.none,
      errorMessage: '',
    );
  }

  LoanState _mapPendingLoans(List<LoanEntity> loans) {
    final isActionLoading = state.status == LoanStatus.loading;
    return state.copyWith(
      pendingLoans: loans,
      status: isActionLoading ? state.status : LoanStatus.initial,
      operation: isActionLoading ? state.operation : LoanOperation.none,
      errorMessage: '',
    );
  }

  LoanState _mapStreamError(Object error) {
    return state.copyWith(
      status: LoanStatus.failure,
      operation: LoanOperation.loadLoans,
      errorMessage: error.toString(),
    );
  }

  Future<void> _onLoadLoansRequested(
    LoadLoansRequested event,
    Emitter<LoanState> emit,
  ) async {
    if (_hasCurrentUser) {
      await emit.forEach<List<LoanEntity>>(
        _getUserLoansUseCase.execute(),
        onData: _mapUserLoans,
        onError: (error, _) => _mapStreamError(error),
      );
    }
  }

  Future<void> _onLoadPendingLoansRequested(
    LoadPendingLoansRequested event,
    Emitter<LoanState> emit,
  ) async {
    if (_hasCurrentUser) {
      await emit.forEach<List<LoanEntity>>(
        _getPendingLoansUseCase.execute(),
        onData: _mapPendingLoans,
        onError: (error, _) => _mapStreamError(error),
      );
    }
  }

  Future<void> _onSubmitLoanRequested(
    SubmitLoanRequested event,
    Emitter<LoanState> emit,
  ) async {
    emit(
      state.copyWith(
        status: LoanStatus.loading,
        operation: LoanOperation.submit,
        errorMessage: '',
      ),
    );
    try {
      await _submitLoanUseCase
          .execute(
            amount: event.amount,
            purpose: event.purpose,
            duration: event.duration,
            interestRate: event.interestRate,
          )
          .timeout(const Duration(seconds: 15));

      emit(
        state.copyWith(
          status: LoanStatus.success,
          operation: LoanOperation.submit,
          errorMessage: '',
        ),
      );
    } on Exception catch (e) {
      final msg = e.toString();
      emit(
        state.copyWith(
          status: LoanStatus.failure,
          operation: LoanOperation.submit,
          errorMessage: msg.contains('TimeoutException')
              ? "Request timed out. Please check your network connection."
              : msg.replaceFirst("Exception: ", ""),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: LoanStatus.failure,
          operation: LoanOperation.submit,
          errorMessage: e.toString().replaceFirst("Exception: ", ""),
        ),
      );
    }
  }

  Future<void> _onApproveLoanRequested(
    ApproveLoanRequested event,
    Emitter<LoanState> emit,
  ) async {
    emit(
      state.copyWith(
        status: LoanStatus.loading,
        operation: LoanOperation.approve,
        errorMessage: '',
      ),
    );
    try {
      await _approveLoanUseCase.execute(event.loanId);
      emit(
        state.copyWith(
          status: LoanStatus.success,
          operation: LoanOperation.approve,
          errorMessage: '',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: LoanStatus.failure,
          operation: LoanOperation.approve,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onRejectLoanRequested(
    RejectLoanRequested event,
    Emitter<LoanState> emit,
  ) async {
    emit(
      state.copyWith(
        status: LoanStatus.loading,
        operation: LoanOperation.reject,
        errorMessage: '',
      ),
    );
    try {
      await _rejectLoanUseCase.execute(event.loanId);
      emit(
        state.copyWith(
          status: LoanStatus.success,
          operation: LoanOperation.reject,
          errorMessage: '',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: LoanStatus.failure,
          operation: LoanOperation.reject,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onClearLoanError(ClearLoanError event, Emitter<LoanState> emit) {
    emit(
      state.copyWith(
        status: LoanStatus.initial,
        operation: LoanOperation.none,
        errorMessage: '',
      ),
    );
  }
}
