import 'package:equatable/equatable.dart';

abstract class LoanEvent extends Equatable {
  const LoanEvent();

  @override
  List<Object?> get props => [];
}

class LoadLoansRequested extends LoanEvent {
  const LoadLoansRequested();
}

class LoadPendingLoansRequested extends LoanEvent {
  const LoadPendingLoansRequested();
}

class SubmitLoanRequested extends LoanEvent {
  final double amount;
  final String purpose;
  final String duration;
  final double interestRate;

  const SubmitLoanRequested({
    required this.amount,
    required this.purpose,
    required this.duration,
    required this.interestRate,
  });

  @override
  List<Object?> get props => [amount, purpose, duration, interestRate];
}

class ApproveLoanRequested extends LoanEvent {
  final String loanId;

  const ApproveLoanRequested(this.loanId);

  @override
  List<Object?> get props => [loanId];
}

class RejectLoanRequested extends LoanEvent {
  final String loanId;

  const RejectLoanRequested(this.loanId);

  @override
  List<Object?> get props => [loanId];
}

class ClearLoanError extends LoanEvent {
  const ClearLoanError();
}
