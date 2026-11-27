import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/share_model.dart';

class FirebaseShareDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const int _defaultMaxQuantityPerPurchase = 1000;

  double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.replaceAll(',', '').trim()) ?? 0.0;
    }
    return 0.0;
  }

  int _parseInt(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value.replaceAll(',', '').trim()) ?? 0;
    }
    return 0;
  }

  double _shareDocTotal(Map<String, dynamic> data) {
    final status = data['status']?.toString().toLowerCase() ?? 'approved';
    if (status == 'rejected') return 0.0;
    final total = _parseDouble(data['totalAmount']);
    if (total != 0) return total;
    final qty = _parseDouble(data['quantity']);
    final unit = _parseDouble(data['unitPrice']);
    return qty * unit;
  }

  double _effectiveSharePrice(Map<String, dynamic> groupData) {
    final dedicated = _parseDouble(groupData['sharePrice']);
    if (dedicated > 0) return dedicated;
    return _parseDouble(groupData['contributionAmount']);
  }

  Stream<List<ShareModel>> getMyShares() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.error("User not logged in");

    return _firestore
        .collection("shares")
        .where("userId", isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => ShareModel.fromMap(doc.data(), doc.id))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<void> buyShares({
    required String groupId,
    required int quantity,
    String paymentMethod = 'M-Pesa',
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");
    if (quantity <= 0) throw Exception("Quantity must be greater than zero");

    final groupDoc =
        await _firestore.collection("groups").doc(groupId).get();
    if (!groupDoc.exists) throw Exception("Group not found");

    final groupData = groupDoc.data() ?? const <String, dynamic>{};
    final members = groupData['members'];
    if (members is! List || !members.contains(user.uid)) {
      throw Exception("You are not a member of this group");
    }

    final maxQty = _parseInt(groupData['maxSharesPerPurchase']);
    final limit = maxQty > 0 ? maxQty : _defaultMaxQuantityPerPurchase;
    if (quantity > limit) {
      throw Exception("Quantity exceeds the group maximum of $limit shares");
    }

    final unitPrice = _effectiveSharePrice(groupData);
    if (unitPrice <= 0) throw Exception("Invalid share price for this group");

    await _firestore.collection("shares").add({
      'userId': user.uid,
      'groupId': groupId,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalAmount': quantity * unitPrice,
      'paymentMethod': paymentMethod,
      'status': 'approved',
      'type': 'purchase',
      'createdAt': Timestamp.now(),
    });
  }

  Future<void> redeemShares({
    required String groupId,
    required int quantity,
    String paymentMethod = 'M-Pesa',
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");
    if (quantity <= 0) throw Exception("Quantity must be greater than zero");

    final groupDoc =
        await _firestore.collection("groups").doc(groupId).get();
    if (!groupDoc.exists) throw Exception("Group not found");

    final groupData = groupDoc.data() ?? const <String, dynamic>{};
    final members = groupData['members'];
    if (members is! List || !members.contains(user.uid)) {
      throw Exception("You are not a member of this group");
    }

    // Verify member holds enough net shares in this group.
    final mySharesSnap = await _firestore
        .collection("shares")
        .where("userId", isEqualTo: user.uid)
        .get();

    int owned = 0;
    for (final doc in mySharesSnap.docs) {
      final data = doc.data();
      if (data['groupId']?.toString() != groupId) continue;
      final status = data['status']?.toString().toLowerCase() ?? 'approved';
      if (status == 'rejected') continue;
      owned += _parseInt(data['quantity']);
    }

    if (quantity > owned) {
      throw Exception(
        "Insufficient shares. You currently own $owned share${owned == 1 ? '' : 's'} in this group.",
      );
    }

    final unitPrice = _effectiveSharePrice(groupData);
    if (unitPrice <= 0) throw Exception("Invalid share price for this group");

    await _firestore.collection("shares").add({
      'userId': user.uid,
      'groupId': groupId,
      'quantity': -quantity,
      'unitPrice': unitPrice,
      'totalAmount': -(quantity * unitPrice),
      'paymentMethod': paymentMethod,
      'status': 'approved',
      'type': 'redemption',
      'createdAt': Timestamp.now(),
    });
  }

  Future<void> updateShareStatus(String shareId, String status) async {
    await _firestore.collection("shares").doc(shareId).update({
      'status': status,
      'reviewedAt': Timestamp.now(),
    });
  }

  Future<double> getShareCapital(String groupId) async {
    final snapshot = await _firestore
        .collection("shares")
        .where("groupId", isEqualTo: groupId)
        .get();

    double total = 0;
    for (final doc in snapshot.docs) {
      total += _shareDocTotal(doc.data());
    }
    return total < 0 ? 0.0 : total;
  }

  Stream<double> watchShareCapital(String groupId) {
    return _firestore
        .collection("shares")
        .where("groupId", isEqualTo: groupId)
        .snapshots()
        .map((snapshot) {
      double total = 0;
      for (final doc in snapshot.docs) {
        total += _shareDocTotal(doc.data());
      }
      return total < 0 ? 0.0 : total;
    });
  }
}
