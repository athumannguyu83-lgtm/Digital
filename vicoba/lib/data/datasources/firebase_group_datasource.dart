import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/group_member_entity.dart';
import '../../domain/entities/join_request_entity.dart';
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

  // ---------------------------------------------------------------------------
  // Group details, join requests & members
  // ---------------------------------------------------------------------------

  CollectionReference<Map<String, dynamic>> _requests(String groupId) =>
      _firestore.collection('groups').doc(groupId).collection('joinRequests');

  Stream<GroupModel?> watchGroup(String groupId) {
    return _firestore.collection('groups').doc(groupId).snapshots().map((doc) {
      final data = doc.data();
      if (!doc.exists || data == null) return null;
      return GroupModel.fromMap(data, doc.id);
    });
  }

  /// Emits the current user's request status for the group
  /// (pending / approved / rejected), or null if they never requested.
  Stream<String?> watchMyJoinRequestStatus(String groupId) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(null);
    return _requests(groupId)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.data()?['status']?.toString());
  }

  Future<String> requestToJoin(String groupId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    final groupRef = _firestore.collection('groups').doc(groupId);
    final group = await groupRef.get();
    if (!group.exists) throw Exception("Group not found");

    final groupData = group.data() ?? const <String, dynamic>{};
    final members = groupData['members'];
    if (members is List && members.contains(user.uid)) {
      throw Exception("You are already a member of this group");
    }

    // Ensure the group has a persisted join code so the member can join via it.
    String groupCode = groupData['groupCode']?.toString().trim() ?? '';
    if (groupCode.isEmpty) {
      groupCode = _generateGroupCode();
      await groupRef.update({'groupCode': groupCode});
    }

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final name = userDoc.data()?['name']?.toString().trim();

    await _requests(groupId).doc(user.uid).set({
      'userId': user.uid,
      'userName': (name != null && name.isNotEmpty)
          ? name
          : (user.email ?? 'Member'),
      'status': 'pending',
      'joinCode': groupCode,
      'createdAt': Timestamp.now(),
    });

    return groupCode;
  }

  Stream<List<JoinRequestEntity>> watchPendingJoinRequests(String groupId) {
    return _requests(groupId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
      final requests = snapshot.docs.map((doc) {
        final data = doc.data();
        final created = data['createdAt'];
        return JoinRequestEntity(
          userId: data['userId']?.toString() ?? doc.id,
          userName: data['userName']?.toString() ?? 'Member',
          status: data['status']?.toString() ?? 'pending',
          createdAt: created is Timestamp ? created.toDate() : null,
        );
      }).toList();
      // Oldest request first.
      requests.sort((a, b) {
        final aTime = a.createdAt;
        final bTime = b.createdAt;
        if (aTime == null || bTime == null) return 0;
        return aTime.compareTo(bTime);
      });
      return requests;
    });
  }

  Future<void> _assertOwner(DocumentReference<Map<String, dynamic>> groupRef) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");
    final group = await groupRef.get();
    if (!group.exists) throw Exception("Group not found");
    if (group.data()?['ownerId'] != uid) {
      throw Exception("Only the group administrator can review requests");
    }
  }

  Future<void> approveJoinRequest(String groupId, String userId) async {
    final groupRef = _firestore.collection('groups').doc(groupId);
    await _assertOwner(groupRef);

    final group = await groupRef.get();
    final members = group.data()?['members'];
    final alreadyMember = members is List && members.contains(userId);

    final batch = _firestore.batch();
    batch.update(_requests(groupId).doc(userId), {
      'status': 'approved',
      'reviewedAt': Timestamp.now(),
    });
    if (!alreadyMember) {
      batch.update(groupRef, {
        'members': FieldValue.arrayUnion([userId]),
        'memberCount': FieldValue.increment(1),
      });
    }
    await batch.commit();
  }

  Future<void> rejectJoinRequest(String groupId, String userId) async {
    final groupRef = _firestore.collection('groups').doc(groupId);
    await _assertOwner(groupRef);
    await _requests(groupId).doc(userId).update({
      'status': 'rejected',
      'reviewedAt': Timestamp.now(),
    });
  }

  Future<List<GroupMemberEntity>> getGroupMembers(String groupId) async {
    final groupDoc = await _firestore.collection('groups').doc(groupId).get();
    if (!groupDoc.exists) return const [];
    final groupData = groupDoc.data() ?? const {};
    final rawMembers = groupData['members'];
    final members = rawMembers is List
        ? rawMembers.map((e) => e.toString()).toList()
        : const <String>[];
    final ownerId = groupData['ownerId']?.toString();

    final result = await Future.wait(members.map((uid) async {
      String name = 'Member';
      try {
        final doc = await _firestore.collection('users').doc(uid).get();
        final value = doc.data()?['name']?.toString().trim();
        if (value != null && value.isNotEmpty) name = value;
      } catch (_) {
        // Fall back to the generic label if the profile can't be read.
      }
      return GroupMemberEntity(
        id: uid,
        name: name,
        isOwner: uid == ownerId,
      );
    }));

    // Owner first, then alphabetical.
    result.sort((a, b) {
      if (a.isOwner != b.isOwner) return a.isOwner ? -1 : 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return result;
  }
}
