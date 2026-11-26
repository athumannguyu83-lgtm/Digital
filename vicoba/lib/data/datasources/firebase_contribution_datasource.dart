import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/contribution_model.dart';

class FirebaseContributionDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addContribution(Map<String, dynamic> contributionData) async {
    final userId = _auth.currentUser?.uid;
    final groupId = contributionData['groupId']?.toString();

    if (userId == null) {
      throw Exception("User not logged in");
    }
    if (groupId == null || groupId.isEmpty) {
      throw Exception("Group ID is required");
    }

    final groupDoc = await _firestore.collection("groups").doc(groupId).get();
    if (!groupDoc.exists) {
      throw Exception("Group not found");
    }
    final members = groupDoc.data()?['members'];
    if (members is! List || !members.contains(userId)) {
      throw Exception("You are not a member of this group");
    }

    await _firestore.collection("contributions").add(contributionData);
  }

  Stream<List<ContributionModel>> getUserContributions() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.error("User not logged in");
    }

    return _firestore
        .collection("contributions")
        .where("userId", isEqualTo: userId)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ContributionModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<ContributionModel>> getGroupContributions(String groupId) {
    return _firestore
        .collection("contributions")
        .where("groupId", isEqualTo: groupId)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ContributionModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<ContributionModel>> getContributionsByFilter({
    String? status,
    String? paymentMethod,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.error("User not logged in");
    }

    Query query = _firestore
        .collection("contributions")
        .where("userId", isEqualTo: userId);

    if (status != null) {
      query = query.where("status", isEqualTo: status);
    }

    if (paymentMethod != null) {
      query = query.where("paymentMethod", isEqualTo: paymentMethod);
    }

    if (startDate != null) {
      query = query.where("createdAt", isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }

    if (endDate != null) {
      query = query.where("createdAt", isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }

    return query
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ContributionModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  double _parseAmount(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.replaceAll(',', '').trim()) ?? 0.0;
    }
    return 0.0;
  }

  Future<double> getTotalContributions() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Future.error("User not logged in");
    }

    final snapshot = await _firestore
        .collection("contributions")
        .where("userId", isEqualTo: userId)
        .where("status", isEqualTo: "completed")
        .get();

    double total = 0;
    for (var doc in snapshot.docs) {
      total += _parseAmount(doc.data()["amount"]);
    }

    return total;
  }

  Future<double> getTotalContributionsByGroup(String groupId) async {
    final snapshot = await _firestore
        .collection("contributions")
        .where("groupId", isEqualTo: groupId)
        .where("status", isEqualTo: "completed")
        .get();

    double total = 0;
    for (var doc in snapshot.docs) {
      total += _parseAmount(doc.data()["amount"]);
    }

    return total;
  }
}