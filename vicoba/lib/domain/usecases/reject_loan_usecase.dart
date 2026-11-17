import '../repositories/loan_repository.dart';

class RejectLoanUseCase {
  final LoanRepository _loanRepository;

  RejectLoanUseCase(this._loanRepository);

  Future<void> execute(String loanId) async {
    await _loanRepository.rejectLoan(loanId);
  }
}