import '../repositories/loan_repository.dart';

class SubmitLoanUseCase {
  final LoanRepository _loanRepository;

  SubmitLoanUseCase(this._loanRepository);

  Future<void> execute({
    required double amount,
    required String purpose,
    required String duration,
    required double interestRate,
  }) async {
    await _loanRepository.submitLoan(
      amount: amount,
      purpose: purpose,
      duration: duration,
      interestRate: interestRate,
    );
  }
}