import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/contribution_entity.dart';

class ContributionModel {
  final String? id;
  final String userId;
  final String groupId;
  final double amount;
  final String paymentMethod;
  final String status;
  final Timestamp contributionDate;
  final Timestamp createdAt;

  ContributionModel({
    this.id,
    required this.userId,
    required this.groupId,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    required this.contributionDate,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "userId": userId,
      "groupId": groupId,
      "amount": amount,
      "paymentMethod": paymentMethod,
      "status": status,
      "contributionDate": contributionDate,
      "createdAt": createdAt,
    };
  }

  factory ContributionModel.fromMap(Map<String, dynamic> map, String docId) {
    return ContributionModel(
      id: docId,
      userId: map["userId"] ?? '',
      groupId: map["groupId"] ?? '',
      amount: (map["amount"] as num?)?.toDouble() ?? 0.0,
      paymentMethod: map["paymentMethod"] ?? '',
      status: map["status"] ?? 'pending',
      contributionDate: map["contributionDate"] ?? Timestamp.now(),
      createdAt: map["createdAt"] ?? Timestamp.now(),
    );
  }

  ContributionEntity toEntity() {
    return ContributionEntity(
      id: id,
      userId: userId,
      groupId: groupId,
      amount: amount,
      paymentMethod: paymentMethod,
      status: status,
      contributionDate: contributionDate.toDate(),
      createdAt: createdAt.toDate(),
    );
  }
}