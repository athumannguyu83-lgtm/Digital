import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/loan_model.dart';

class FirebaseLoanDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addLoanRequest(Map<String, dynamic> loanData) async {
    await _firestore.collection("loan_requests").add(loanData);
  }

  Stream<List<LoanModel>> getUserLoans(String userId) {
    return _firestore
        .collection("loan_requests")
        .where("userId", isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              try {
                return LoanModel.fromMap(doc.data(), doc.id);
              } catch (_) {
                return null;
              }
            })
            .whereType<LoanModel>()
            .toList());
  }

  Stream<List<LoanModel>> getPendingLoans() {
    return _firestore
        .collection("loan_requests")
        .where("status", isEqualTo: "pending")
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              try {
                return LoanModel.fromMap(doc.data(), doc.id);
              } catch (_) {
                return null;
              }
            })
            .whereType<LoanModel>()
            .toList());
  }

  Future<void> updateLoanStatus(String loanId, String status) async {
    await _firestore
        .collection("loan_requests")
        .doc(loanId)
        .update({"status": status});
  }
}