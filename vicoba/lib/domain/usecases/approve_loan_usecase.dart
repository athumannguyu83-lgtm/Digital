import '../repositories/loan_repository.dart';

class ApproveLoanUseCase {
  final LoanRepository _loanRepository;

  ApproveLoanUseCase(this._loanRepository);

  Future<void> execute(String loanId) async {
    await _loanRepository.approveLoan(loanId);
  }
}