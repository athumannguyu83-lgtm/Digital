import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/share_entity.dart';

class ShareModel {
  final String id;
  final String userId;
  final String groupId;
  final int quantity;
  final double unitPrice;
  final double totalAmount;
  final String paymentMethod;
  final String status;
  final String type;
  final DateTime createdAt;

  ShareModel({
    required this.id,
    required this.userId,
    required this.groupId,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
    this.paymentMethod = 'M-Pesa',
    this.status = 'approved',
    this.type = 'purchase',
    required this.createdAt,
  });

  static double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.replaceAll(',', '').trim()) ?? 0.0;
    }
    return 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value.replaceAll(',', '').trim()) ?? 0;
    }
    return 0;
  }

  factory ShareModel.fromMap(Map<String, dynamic> map, String id) {
    final created = map['createdAt'];
    final quantity = _parseInt(map['quantity']);
    final unitPrice = _parseDouble(map['unitPrice']);
    final parsedTotal = _parseDouble(map['totalAmount']);
    final totalAmount = parsedTotal != 0 ? parsedTotal : quantity * unitPrice;
    final rawMethod = map['paymentMethod']?.toString().trim();
    final rawStatus = map['status']?.toString().trim();
    final rawType = map['type']?.toString().trim();

    return ShareModel(
      id: id,
      userId: map['userId']?.toString() ?? '',
      groupId: map['groupId']?.toString() ?? '',
      quantity: quantity,
      unitPrice: unitPrice,
      totalAmount: totalAmount,
      paymentMethod:
          (rawMethod != null && rawMethod.isNotEmpty) ? rawMethod : 'M-Pesa',
      status:
          (rawStatus != null && rawStatus.isNotEmpty) ? rawStatus : 'approved',
      type: (rawType != null && rawType.isNotEmpty)
          ? rawType
          : (quantity < 0 ? 'redemption' : 'purchase'),
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
      paymentMethod: paymentMethod,
      status: status,
      type: type,
      createdAt: createdAt,
    );
  }
}
