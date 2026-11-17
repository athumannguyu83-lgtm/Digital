import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/loan_entity.dart';

class LoanModel {
  final String? id;
  final String userId;
  final double amount;
  final String purpose;
  final String duration;
  final double interestRate;
  final String status;
  final Timestamp createdAt;

  LoanModel({
    this.id,
    required this.userId,
    required this.amount,
    required this.purpose,
    required this.duration,
    required this.interestRate,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "userId": userId,
      "amount": amount,
      "purpose": purpose,
      "duration": duration,
      "interestRate": interestRate,
      "status": status,
      "createdAt": createdAt,
    };
  }

  factory LoanModel.fromMap(Map<String, dynamic> map, String docId) {
    return LoanModel(
      id: docId,
      userId: map["userId"] ?? '',
      amount: (map["amount"] as num?)?.toDouble() ?? 0.0,
      purpose: map["purpose"] ?? '',
      duration: map["duration"] ?? '',
      interestRate: (map["interestRate"] as num?)?.toDouble() ?? 0.0,
      status: map["status"] ?? 'pending',
      createdAt: map["createdAt"] ?? Timestamp.now(),
    );
  }

  LoanEntity toEntity() {
    return LoanEntity(
      id: id,
      userId: userId,
      amount: amount,
      purpose: purpose,
      duration: duration,
      interestRate: interestRate,
      status: status,
      createdAt: createdAt.toDate(),
    );
  }
}