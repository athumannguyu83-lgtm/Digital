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

  static double _parseAmount(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.replaceAll(',', '').trim()) ?? 0.0;
    }
    return 0.0;
  }

  factory ContributionModel.fromMap(Map<String, dynamic> map, String docId) {
    return ContributionModel(
      id: docId,
      userId: map["userId"]?.toString() ?? '',
      groupId: map["groupId"]?.toString() ?? '',
      amount: _parseAmount(map["amount"]),
      paymentMethod: map["paymentMethod"]?.toString() ?? '',
      status: map["status"]?.toString() ?? 'pending',
      contributionDate: map["contributionDate"] is Timestamp
          ? map["contributionDate"] as Timestamp
          : Timestamp.now(),
      createdAt: map["createdAt"] is Timestamp
          ? map["createdAt"] as Timestamp
          : Timestamp.now(),
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