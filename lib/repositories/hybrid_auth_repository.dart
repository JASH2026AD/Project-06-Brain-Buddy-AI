import 'package:firebase_core/firebase_core.dart';

import '../models/app_user.dart';
import 'auth_repository.dart';
import 'firebase_auth_repository.dart';
import 'mock_auth_repository.dart';

class HybridAuthRepository implements AuthRepository {
  HybridAuthRepository({
    FirebaseAuthRepository? firebaseAuthRepository,
    MockAuthRepository? mockAuthRepository,
  })  : _firebaseAuthRepo = firebaseAuthRepository ?? FirebaseAuthRepository(),
        _mockAuthRepo = mockAuthRepository ?? MockAuthRepository();

  final FirebaseAuthRepository _firebaseAuthRepo;
  final MockAuthRepository _mockAuthRepo;

  bool get _isFirebaseActive {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  AuthRepository get _activeRepo {
    if (_isFirebaseActive) {
      return _firebaseAuthRepo;
    }
    return _mockAuthRepo;
  }

  @override
  Stream<AppUser?> get authStateChanges => _activeRepo.authStateChanges;

  @override
  AppUser? get currentUser => _activeRepo.currentUser;

  @override
  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _activeRepo.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      if (_isFallbackError(e)) {
        return _mockAuthRepo.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      }
      rethrow;
    }
  }

  @override
  Future<AppUser> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      return await _activeRepo.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );
    } catch (e) {
      if (_isFallbackError(e)) {
        return _mockAuthRepo.signUpWithEmailAndPassword(
          email: email,
          password: password,
          displayName: displayName,
        );
      }
      rethrow;
    }
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    try {
      return await _activeRepo.signInWithGoogle();
    } catch (e) {
      if (_isFallbackError(e) || e is UnimplementedError) {
        return _mockAuthRepo.signInWithGoogle();
      }
      rethrow;
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _activeRepo.sendPasswordResetEmail(email);
    } catch (e) {
      if (_isFallbackError(e)) {
        await _mockAuthRepo.sendPasswordResetEmail(email);
        return;
      }
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _activeRepo.signOut();
    } catch (_) {
      await _mockAuthRepo.signOut();
    }
  }

  bool _isFallbackError(Object e) {
    final String msg = e.toString().toLowerCase();
    return msg.contains('no-app') ||
        msg.contains('not-configured') ||
        msg.contains('unsupportederror') ||
        msg.contains('firebase has not been initialized');
  }
}
