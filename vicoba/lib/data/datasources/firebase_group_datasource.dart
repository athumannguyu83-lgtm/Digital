import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/group_model.dart';

class FirebaseGroupDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _generateGroupCode() {
    final random = Random.secure();
    final digits = List.generate(6, (_) => random.nextInt(10)).join();
    return 'VIC-$digits';
  }

  Stream<List<GroupModel>> getUserGroups() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.error("User not logged in");
    }

    return _firestore
        .collection("groups")
        .where("members", arrayContains: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GroupModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<GroupModel?> getGroupByCode(String code) async {
    final snapshot = await _firestore
        .collection("groups")
        .where("groupCode", isEqualTo: code.trim().toUpperCase())
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    final doc = snapshot.docs.first;
    return GroupModel.fromMap(doc.data(), doc.id);
  }

  Future<String> createGroup({
    required String name,
    required double contributionAmount,
    required String contributionFrequency,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }

    final docRef = await _firestore.collection("groups").add({
      'groupName': name,
      'contributionAmount': contributionAmount,
      'contributionFrequency': contributionFrequency,
      'groupCode': _generateGroupCode(),
      'members': [user.uid],
      'memberCount': 1,
      'ownerId': user.uid,
      'createdAt': Timestamp.now(),
    });

    return docRef.id;
  }

  Future<void> joinGroup(String groupId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }

    final docRef = _firestore.collection("groups").doc(groupId);
    final doc = await docRef.get();
    if (!doc.exists) {
      throw Exception("Group not found");
    }
    final members = doc.data()?['members'];
    if (members is List && members.contains(user.uid)) {
      return; // already a member; nothing to do
    }

    await docRef.update({
      'members': FieldValue.arrayUnion([user.uid]),
      'memberCount': FieldValue.increment(1),
    });
  }

  Future<bool> isGroupMember(String groupId, String userId) async {
    final doc = await _firestore.collection("groups").doc(groupId).get();
    if (!doc.exists) return false;
    final members = doc.data()?['members'];
    return members is List && members.contains(userId);
  }
}
