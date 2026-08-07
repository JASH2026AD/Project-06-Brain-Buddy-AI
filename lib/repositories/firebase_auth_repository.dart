import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';

import '../models/app_user.dart';
import 'auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    fb.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _customAuth = firebaseAuth,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  final fb.FirebaseAuth? _customAuth;
  final GoogleSignIn _googleSignIn;

  fb.FirebaseAuth get _auth => _customAuth ?? fb.FirebaseAuth.instance;

  @override
  Stream<AppUser?> get authStateChanges {
    return _auth.authStateChanges().map(_mapFirebaseUser);
  }

  @override
  AppUser? get currentUser {
    try {
      final fb.User? user = _auth.currentUser;
      return user != null ? _mapFirebaseUser(user) : null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final fb.UserCredential credential = await _auth
        .signInWithEmailAndPassword(email: email, password: password);
    if (credential.user == null) {
      throw Exception('Authentication failed: User is null after sign in.');
    }
    return _mapFirebaseUser(credential.user!)!;
  }

  @override
  Future<AppUser> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final fb.UserCredential credential = await _auth
        .createUserWithEmailAndPassword(email: email, password: password);

    final fb.User? user = credential.user;
    if (user == null) {
      throw Exception('Registration failed: User is null after sign up.');
    }

    if (displayName != null && displayName.isNotEmpty) {
      await user.updateDisplayName(displayName);
      await user.reload();
    }

    final fb.User updatedUser = _auth.currentUser ?? user;
    return _mapFirebaseUser(updatedUser)!;
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Google Sign-In was cancelled by the user.');
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final fb.OAuthCredential credential = fb.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final fb.UserCredential userCredential =
        await _auth.signInWithCredential(credential);
    final fb.User? user = userCredential.user;
    if (user == null) {
      throw Exception('Google Sign-In failed: User is null after authentication.');
    }

    return _mapFirebaseUser(user)!;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  AppUser? _mapFirebaseUser(fb.User? user) {
    if (user == null) return null;
    return AppUser(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
      isEmailVerified: user.emailVerified,
      createdAt: user.metadata.creationTime,
    );
  }
}
