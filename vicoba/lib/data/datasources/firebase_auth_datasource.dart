import 'dart:async';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseAuthDataSource {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> createUserDocument({
    required String uid,
    required Map<String, dynamic> userData,
  }) async {
    await _firestore.collection("users").doc(uid).set(userData);
  }

  Future<DocumentSnapshot> getUserDocument(String uid) async {
    return await _firestore.collection("users").doc(uid).get();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  Future<void> updateUserDocument({
    required String uid,
    required Map<String, dynamic> userData,
  }) async {
    await _firestore.collection("users").doc(uid).update(userData);
  }

  Future<void> deleteUserDocument(String uid) async {
    await _firestore.collection("users").doc(uid).delete();
  }

  Future<String> uploadProfilePhoto(
    String uid,
    Uint8List imageBytes, {
    required String contentType,
    void Function(double progress)? onProgress,
  }) async {
    const maxProfilePhotoBytes = 5 * 1024 * 1024;
    if (imageBytes.isEmpty || imageBytes.length >= maxProfilePhotoBytes) {
      throw const FormatException('Profile photos must be smaller than 5 MB.');
    }

    if (!const {
      'image/jpeg',
      'image/png',
      'image/webp',
    }.contains(contentType)) {
      throw const FormatException('Choose a JPEG, PNG, or WebP image.');
    }

    final ext = switch (contentType) {
      'image/jpeg' => '.jpg',
      'image/png' => '.png',
      'image/webp' => '.webp',
      _ => '',
    };
    final reference =
        _storage.ref().child('profile_photos/$uid/profile$ext');
    final uploadTask = reference.putData(
      imageBytes,
      SettableMetadata(contentType: contentType),
    );

    StreamSubscription<TaskSnapshot>? progressSubscription;
    if (onProgress != null) {
      progressSubscription = uploadTask.snapshotEvents.listen(
        (snapshot) {
          if (snapshot.totalBytes > 0) {
            onProgress(snapshot.bytesTransferred / snapshot.totalBytes);
          }
        },
        onError: (_) {
          // Upload errors are handled by awaiting uploadTask below.
        },
      );
    }

    try {
      final snapshot = await uploadTask;
      return snapshot.ref.fullPath;
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found' || e.code == 'bucket-not-found') {
        throw StateError(
          'Firebase Storage bucket "${_storage.bucket}" is not available. '
          'Enable Firebase Storage in the Firebase Console and deploy storage.rules.',
        );
      }
      rethrow;
    } finally {
      await progressSubscription?.cancel();
    }
  }

  Future<Uint8List?> getProfilePhoto(String storageReference) async {
    const maxProfilePhotoBytes = 5 * 1024 * 1024;

    Reference reference;
    if (storageReference.startsWith('https://')) {
      reference = _storage.refFromURL(storageReference);
    } else {
      reference = _storage.ref().child(storageReference);
    }

    try {
      final bytes = await reference.getData(maxProfilePhotoBytes);
      if (bytes == null || bytes.isEmpty) return null;
      return bytes;
    } on FirebaseException catch (e) {
      // If the exact path is not found, try the legacy extensionless path
      // or the newer path with common image extensions.
      if (e.code == 'object-not-found' &&
          !storageReference.startsWith('https://')) {
        // Try alternative paths: if current has extension, try without;
        // if current has no extension, try with common extensions.
        final hasExtension = RegExp(r'\.(jpe?g|png|webp)$', caseSensitive: false)
            .hasMatch(storageReference);

        final alternatives = hasExtension
            ? [storageReference.replaceAll(RegExp(r'\.(jpe?g|png|webp)$'), '')]
            : [
                '$storageReference.jpg',
                '$storageReference.png',
                '$storageReference.webp',
              ];

        for (final altPath in alternatives) {
          try {
            final altRef = _storage.ref().child(altPath);
            final bytes = await altRef.getData(maxProfilePhotoBytes);
            if (bytes != null && bytes.isNotEmpty) return bytes;
          } on FirebaseException {
            // Try next alternative.
          }
        }
      }
      return null;
    }
  }
}
