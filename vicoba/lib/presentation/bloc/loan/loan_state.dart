import 'package:equatable/equatable.dart';

import '../../../domain/entities/loan_entity.dart';

enum LoanStatus { initial, loading, success, failure }

enum LoanOperation { none, loadLoans, submit, approve, reject }

class LoanState extends Equatable {
  final LoanStatus status;
  final LoanOperation operation;
  final String errorMessage;
  final List<LoanEntity> userLoans;
  final List<LoanEntity> pendingLoans;

  const LoanState({
    this.status = LoanStatus.initial,
    this.operation = LoanOperation.none,
    this.errorMessage = '',
    this.userLoans = const [],
    this.pendingLoans = const [],
  });

  bool get isLoading => status == LoanStatus.loading;

  LoanState copyWith({
    LoanStatus? status,
    LoanOperation? operation,
    String? errorMessage,
    List<LoanEntity>? userLoans,
    List<LoanEntity>? pendingLoans,
  }) {
    return LoanState(
      status: status ?? this.status,
      operation: operation ?? this.operation,
      errorMessage: errorMessage ?? this.errorMessage,
      userLoans: userLoans ?? this.userLoans,
      pendingLoans: pendingLoans ?? this.pendingLoans,
    );
  }

  @override
  List<Object?> get props => [
    status,
    operation,
    errorMessage,
    userLoans,
    pendingLoans,
  ];
}
