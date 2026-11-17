import '../entities/loan_entity.dart';
import '../repositories/loan_repository.dart';

class GetUserLoansUseCase {
  final LoanRepository _loanRepository;

  GetUserLoansUseCase(this._loanRepository);

  Stream<List<LoanEntity>> execute() {
    return _loanRepository.getUserLoans();
  }
}