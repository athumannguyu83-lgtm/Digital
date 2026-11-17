import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/loan_entity.dart';
import '../../domain/repositories/loan_repository.dart';
import '../datasources/firebase_loan_datasource.dart';
import '../models/loan_model.dart';

class LoanRepositoryImpl implements LoanRepository {
  final FirebaseLoanDataSource _loanDataSource;

  LoanRepositoryImpl(this._loanDataSource);

  @override
  Future<void> submitLoan({
    required double amount,
    required String purpose,
    required String duration,
    required double interestRate,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Future.error("User not logged in");
    }

    final loanModel = LoanModel(
      userId: user.uid,
      amount: amount,
      purpose: purpose,
      duration: duration,
      interestRate: interestRate,
      status: "pending",
      createdAt: Timestamp.now(),
    );

    await _loanDataSource.addLoanRequest(loanModel.toMap());
  }

  @override
  Stream<List<LoanEntity>> getUserLoans() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.error("User not logged in");
    }

    return _loanDataSource.getUserLoans(user.uid).map((loanModels) =>
        loanModels.map((model) => model.toEntity()).toList());
  }

  @override
  Stream<List<LoanEntity>> getPendingLoans() {
    return _loanDataSource.getPendingLoans().map((loanModels) =>
        loanModels.map((model) => model.toEntity()).toList());
  }

  @override
  Future<void> approveLoan(String loanId) async {
    await _loanDataSource.updateLoanStatus(loanId, "approved");
  }

  @override
  Future<void> rejectLoan(String loanId) async {
    await _loanDataSource.updateLoanStatus(loanId, "rejected");
  }
}