import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/share_entity.dart';

class ShareModel {
  final String id;
  final String userId;
  final String groupId;
  final int quantity;
  final double unitPrice;
  final double totalAmount;
  final DateTime createdAt;

  ShareModel({
    required this.id,
    required this.userId,
    required this.groupId,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
    required this.createdAt,
  });

  factory ShareModel.fromMap(Map<String, dynamic> map, String id) {
    final created = map['createdAt'];
    return ShareModel(
      id: id,
      userId: map['userId']?.toString() ?? '',
      groupId: map['groupId']?.toString() ?? '',
      quantity: (map['quantity'] as num?)?.toInt() ?? 0,
      unitPrice: (map['unitPrice'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      createdAt: created is Timestamp ? created.toDate() : DateTime.now(),
    );
  }

  ShareEntity toEntity() {
    return ShareEntity(
      id: id,
      userId: userId,
      groupId: groupId,
      quantity: quantity,
      unitPrice: unitPrice,
      totalAmount: totalAmount,
      createdAt: createdAt,
    );
  }
}
