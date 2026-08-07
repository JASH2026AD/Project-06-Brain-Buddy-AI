import 'dart:async';

import '../models/app_user.dart';
import 'auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  MockAuthRepository() {
    _controller = StreamController<AppUser?>.broadcast();
  }

  late final StreamController<AppUser?> _controller;
  AppUser? _currentUser;

  @override
  Stream<AppUser?> get authStateChanges => _controller.stream;

  @override
  AppUser? get currentUser => _currentUser;

  @override
  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final String uid = 'demo-user-${email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')}';
    final AppUser user = AppUser(
      uid: uid,
      email: email,
      displayName: email.split('@').first,
      isEmailVerified: true,
      createdAt: DateTime.now(),
    );
    _currentUser = user;
    _controller.add(user);
    return user;
  }

  @override
  Future<AppUser> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final String uid = 'demo-user-${DateTime.now().millisecondsSinceEpoch}';
    final AppUser user = AppUser(
      uid: uid,
      email: email,
      displayName: displayName ?? email.split('@').first,
      isEmailVerified: true,
      createdAt: DateTime.now(),
    );
    _currentUser = user;
    _controller.add(user);
    return user;
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    return signInWithEmailAndPassword(
      email: 'alex.student@university.edu',
      password: 'demopassword',
    );
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
    _controller.add(null);
  }

  void dispose() {
    _controller.close();
  }
}
