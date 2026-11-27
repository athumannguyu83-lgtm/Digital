import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/share_model.dart';

class FirebaseShareDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const int _maxQuantityPerPurchase = 1000;

  Stream<List<ShareModel>> getMyShares() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.error("User not logged in");

    return _firestore
        .collection("shares")
        .where("userId", isEqualTo: userId)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ShareModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> buyShares({
    required String groupId,
    required int quantity,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");
    if (quantity <= 0) throw Exception("Quantity must be greater than zero");
    if (quantity > _maxQuantityPerPurchase) {
      throw Exception("Quantity exceeds the maximum of $_maxQuantityPerPurchase");
    }

    final groupDoc =
        await _firestore.collection("groups").doc(groupId).get();
    if (!groupDoc.exists) throw Exception("Group not found");

    final groupData = groupDoc.data()!;
    final members = groupData['members'];
    if (members is! List || !members.contains(user.uid)) {
      throw Exception("You are not a member of this group");
    }

    final unitPrice =
        (groupData['contributionAmount'] as num?)?.toDouble() ?? 0.0;
    if (unitPrice <= 0) throw Exception("Invalid share price for this group");

    await _firestore.collection("shares").add({
      'userId': user.uid,
      'groupId': groupId,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalAmount': quantity * unitPrice,
      'createdAt': Timestamp.now(),
    });
  }

  Future<double> getShareCapital(String groupId) async {
    final snapshot = await _firestore
        .collection("shares")
        .where("groupId", isEqualTo: groupId)
        .get();

    double total = 0;
    for (final doc in snapshot.docs) {
      total += (doc.data()["totalAmount"] as num).toDouble();
    }
    return total;
  }
}
