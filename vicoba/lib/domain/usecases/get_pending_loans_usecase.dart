import '../entities/loan_entity.dart';
import '../repositories/loan_repository.dart';

class GetPendingLoansUseCase {
  final LoanRepository _loanRepository;

  GetPendingLoansUseCase(this._loanRepository);

  Stream<List<LoanEntity>> execute() {
    return _loanRepository.getPendingLoans();
  }
}