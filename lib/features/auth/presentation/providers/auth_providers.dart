import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/app_providers.dart';
import '../../../../models/app_user.dart';
import '../../../../models/user_profile.dart';
import '../../../../repositories/auth_repository.dart';
import '../../../../repositories/firebase_auth_repository.dart';
import '../../../../repositories/firestore_profile_repository.dart';
import '../../../../repositories/hybrid_auth_repository.dart';
import '../../../../repositories/mock_auth_repository.dart';
import '../../../../repositories/profile_repository.dart';

final Provider<AuthRepository> authRepositoryProvider = Provider<AuthRepository>(
  (Ref ref) {
    return HybridAuthRepository(
      firebaseAuthRepository: FirebaseAuthRepository(),
      mockAuthRepository: MockAuthRepository(),
    );
  },
);

final Provider<ProfileRepository> profileRepositoryProvider =
    Provider<ProfileRepository>((Ref ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return HybridProfileRepository(hiveService: hiveService);
});

final StreamProvider<AppUser?> authStateProvider = StreamProvider<AppUser?>(
  (Ref ref) => ref.watch(authRepositoryProvider).authStateChanges,
);

final Provider<AppUser?> currentUserProvider = Provider<AppUser?>((Ref ref) {
  final AsyncValue<AppUser?> authState = ref.watch(authStateProvider);
  return authState.asData?.value ?? ref.watch(authRepositoryProvider).currentUser;
});

final StreamProvider<UserProfile?> userProfileProvider =
    StreamProvider<UserProfile?>((Ref ref) async* {
  final AppUser? user = ref.watch(currentUserProvider);
  if (user == null) {
    yield null;
    return;
  }
  final ProfileRepository profileRepo = ref.watch(profileRepositoryProvider);
  yield* profileRepo.watchProfile(user.uid);
});

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  const AuthState({
    this.status = AuthStatus.initial,
    this.errorMessage,
  });

  final AuthStatus status;
  final String? errorMessage;

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  AuthRepository get _authRepo => ref.read(authRepositoryProvider);
  ProfileRepository get _profileRepo => ref.read(profileRepositoryProvider);

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      await _authRepo.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      state = state.copyWith(status: AuthStatus.authenticated);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _cleanErrorMessage(e.toString()),
      );
      return false;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final AppUser user = await _authRepo.signUpWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
        displayName: displayName?.trim(),
      );
      final UserProfile newProfile = UserProfile.empty(user.uid).copyWith(
        fullName: displayName?.trim() ?? '',
      );
      await _profileRepo.saveProfile(newProfile);
      state = state.copyWith(status: AuthStatus.authenticated);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _cleanErrorMessage(e.toString()),
      );
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final AppUser user = await _authRepo.signInWithGoogle();
      final UserProfile? existing = await _profileRepo.getProfile(user.uid);
      if (existing == null) {
        final UserProfile newProfile = UserProfile.empty(user.uid).copyWith(
          fullName: user.displayName ?? '',
        );
        await _profileRepo.saveProfile(newProfile);
      }
      ref.invalidate(userProfileProvider);
      state = state.copyWith(status: AuthStatus.authenticated);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _cleanErrorMessage(e.toString()),
      );
      return false;
    }
  }

  Future<bool> completeStudentProfile({
    required String fullName,
    required String collegeName,
    required String major,
    required String academicYear,
    required double targetGpa,
    String bio = '',
  }) async {
    final AppUser? user = ref.read(currentUserProvider);
    if (user == null) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'User session expired. Please sign in again.',
      );
      return false;
    }

    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final UserProfile profile = UserProfile(
        uid: user.uid,
        fullName: fullName.trim(),
        collegeName: collegeName.trim(),
        major: major.trim(),
        academicYear: academicYear,
        targetGpa: targetGpa,
        bio: bio.trim(),
        isProfileComplete: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _profileRepo.saveProfile(profile);
      ref.invalidate(userProfileProvider);
      state = state.copyWith(status: AuthStatus.authenticated);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _cleanErrorMessage(e.toString()),
      );
      return false;
    }
  }

  Future<bool> sendPasswordReset(String email) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      await _authRepo.sendPasswordResetEmail(email.trim());
      state = state.copyWith(status: AuthStatus.initial);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _cleanErrorMessage(e.toString()),
      );
      return false;
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _authRepo.signOut();
      ref.invalidate(userProfileProvider);
      state = state.copyWith(status: AuthStatus.unauthenticated);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _cleanErrorMessage(e.toString()),
      );
    }
  }

  String _cleanErrorMessage(String error) {
    if (error.contains('user-not-found')) {
      return 'No user account found with this email address.';
    } else if (error.contains('wrong-password')) {
      return 'Incorrect password. Please try again.';
    } else if (error.contains('email-already-in-use')) {
      return 'An account already exists for this email address. Try signing in.';
    } else if (error.contains('invalid-email')) {
      return 'The email address format is invalid.';
    } else if (error.contains('weak-password')) {
      return 'Password is too weak. Must be at least 6 characters.';
    } else if (error.contains('operation-not-allowed')) {
      return 'Email/Password authentication is disabled in Firebase.';
    } else if (error.contains('network-request-failed')) {
      return 'Network error. Please check your internet connection.';
    } else if (error.contains('cancelled') || error.contains('canceled')) {
      return 'Google sign in was cancelled.';
    }
    return error.replaceAll(RegExp(r'^[A-Za-z]+Exception:\s*'), '');
  }
}

final NotifierProvider<AuthController, AuthState> authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);
