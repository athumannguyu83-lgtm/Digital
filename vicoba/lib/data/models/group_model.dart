import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/group_entity.dart';

class GroupModel {
  final String id;
  final String name;
  final double contributionAmount;
  final String contributionFrequency;
  final String? groupCode;
  final List<String> members;
  final int memberCount;
  final String? ownerId;
  final DateTime? createdAt;

  GroupModel({
    required this.id,
    required this.name,
    required this.contributionAmount,
    required this.contributionFrequency,
    this.groupCode,
    this.members = const [],
    this.memberCount = 0,
    this.ownerId,
    this.createdAt,
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
    if (value is String) return int.tryParse(value.trim()) ?? 0;
    return 0;
  }

  factory GroupModel.fromMap(Map<String, dynamic> map, String id) {
    final rawMembers = map['members'];
    return GroupModel(
      id: id,
      name: map['groupName']?.toString() ?? '',
      contributionAmount: _parseDouble(map['contributionAmount']),
      contributionFrequency:
          map['contributionFrequency']?.toString() ?? 'Weekly',
      groupCode: map['groupCode']?.toString(),
      members: rawMembers is List
          ? rawMembers.map((e) => e.toString()).toList()
          : const [],
      memberCount: _parseInt(map['memberCount']),
      ownerId: map['ownerId']?.toString(),
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  GroupEntity toEntity() {
    return GroupEntity(
      id: id,
      name: name,
      contributionAmount: contributionAmount,
      contributionFrequency: contributionFrequency,
      groupCode: groupCode,
      members: members,
      memberCount: memberCount,
      ownerId: ownerId,
    );
  }
}
