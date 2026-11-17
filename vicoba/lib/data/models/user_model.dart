import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final Timestamp createdAt;
  final String? profileImagePath;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.createdAt,
    this.profileImagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "email": email,
      "phone": phone,
      "role": role,
      "createdAt": createdAt,
      "profileImagePath": profileImagePath,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String docId) {
    return UserModel(
      id: docId,
      name: map["name"],
      email: map["email"],
      phone: map["phone"] ?? "",
      role: map["role"],
      createdAt: map["createdAt"],
      profileImagePath:
          map["profileImagePath"] as String? ??
          map["profileImageUrl"] as String?,
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name,
      email: email,
      phone: phone,
      role: role,
      createdAt: createdAt.toDate(),
      profileImagePath: profileImagePath,
    );
  }
}
