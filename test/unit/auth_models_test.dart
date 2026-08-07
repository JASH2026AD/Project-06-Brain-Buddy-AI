import 'package:ai_college_companion/models/app_user.dart';
import 'package:ai_college_companion/models/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppUser Model Unit Tests', () {
    test('AppUser serialization and deserialization works correctly', () {
      final AppUser user = AppUser(
        uid: 'user_123',
        email: 'test.student@university.edu',
        displayName: 'Alex Student',
        isEmailVerified: true,
        createdAt: DateTime(2026, 8, 7),
      );

      final Map<String, dynamic> json = user.toJson();
      expect(json['uid'], 'user_123');
      expect(json['email'], 'test.student@university.edu');

      final AppUser fromJsonUser = AppUser.fromJson(json);
      expect(fromJsonUser.uid, user.uid);
      expect(fromJsonUser.email, user.email);
      expect(fromJsonUser.displayName, user.displayName);
      expect(fromJsonUser.isEmailVerified, true);
    });

    test('AppUser copyWith modifies requested fields', () {
      const AppUser user = AppUser(
        uid: 'user_123',
        email: 'test@university.edu',
      );

      final AppUser updated = user.copyWith(displayName: 'New Name');
      expect(updated.displayName, 'New Name');
      expect(updated.email, 'test@university.edu');
    });
  });

  group('UserProfile Model Unit Tests', () {
    test('UserProfile empty factory defaults correctly', () {
      final UserProfile profile = UserProfile.empty('user_999');
      expect(profile.uid, 'user_999');
      expect(profile.isProfileComplete, false);
      expect(profile.targetGpa, 3.8);
      expect(profile.academicYear, 'Freshman');
    });

    test('UserProfile serialization roundtrip', () {
      final UserProfile profile = UserProfile(
        uid: 'user_456',
        fullName: 'Jane Doe',
        collegeName: 'MIT',
        major: 'Computer Science',
        academicYear: 'Junior',
        targetGpa: 3.95,
        isProfileComplete: true,
      );

      final Map<String, dynamic> json = profile.toJson();
      expect(json['fullName'], 'Jane Doe');
      expect(json['targetGpa'], 3.95);

      final UserProfile restored = UserProfile.fromJson(json);
      expect(restored.fullName, 'Jane Doe');
      expect(restored.collegeName, 'MIT');
      expect(restored.isProfileComplete, true);
    });
  });
}
