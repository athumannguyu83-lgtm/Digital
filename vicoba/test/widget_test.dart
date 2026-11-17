// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:vicoba/core/dependency_injection.dart';
import 'package:vicoba/core/profile_photo_validator.dart';
import 'package:vicoba/data/models/user_model.dart';
import 'package:vicoba/domain/repositories/auth_repository.dart';
import 'package:vicoba/domain/repositories/contribution_repository.dart';
import 'package:vicoba/domain/repositories/loan_repository.dart';
import 'package:vicoba/presentation/bloc/auth/auth_bloc.dart';

void main() {
  tearDown(() async => Get.reset());

  test('registers dependencies using the types requested by the app', () {
    DependencyInjection.init();

    expect(Get.isRegistered<AuthBloc>(), isTrue);
    expect(Get.isRegistered<AuthRepository>(), isTrue);
    expect(Get.isRegistered<LoanRepository>(), isTrue);
    expect(Get.isRegistered<ContributionRepository>(), isTrue);
  });

  test('preserves profile photo path when converting user data', () {
    final model = UserModel(
      id: 'member-id',
      name: 'Member',
      email: 'member@example.com',
      phone: '',
      role: 'member',
      createdAt: Timestamp.fromDate(DateTime(2026, 1, 1)),
      profileImagePath: 'profile_photos/member-id/profile',
    );

    final restored = UserModel.fromMap(model.toMap(), model.id).toEntity();

    expect(restored.profileImagePath, model.profileImagePath);
    expect(
      UserModel.fromMap({
        'name': 'Legacy Member',
        'email': 'legacy@example.com',
        'phone': '',
        'role': 'member',
        'createdAt': Timestamp.fromDate(DateTime(2025, 1, 1)),
        'profileImageUrl': 'https://example.com/legacy.jpg',
      }, 'legacy-id').profileImagePath,
      'https://example.com/legacy.jpg',
    );
  });

  test('rejects non-image and oversized profile photos', () async {
    await expectLater(
      ProfilePhotoValidator.validate(Uint8List.fromList([1, 2, 3])),
      throwsA(isA<FormatException>()),
    );
    await expectLater(
      ProfilePhotoValidator.validate(Uint8List(ProfilePhotoValidator.maxBytes)),
      throwsA(isA<FormatException>()),
    );
  });

  test('rejects corrupted files with a supported image signature', () async {
    await expectLater(
      ProfilePhotoValidator.validate(
        Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]),
      ),
      throwsA(isA<FormatException>()),
    );
  });
}
