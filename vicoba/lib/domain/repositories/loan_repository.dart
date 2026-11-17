import '../entities/loan_entity.dart';

abstract class LoanRepository {
  Future<void> submitLoan({
    required double amount,
    required String purpose,
    required String duration,
    required double interestRate,
  });

  Stream<List<LoanEntity>> getUserLoans();
  Stream<List<LoanEntity>> getPendingLoans();
  Future<void> approveLoan(String loanId);
  Future<void> rejectLoan(String loanId);
}