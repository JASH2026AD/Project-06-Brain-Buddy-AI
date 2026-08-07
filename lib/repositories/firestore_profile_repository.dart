import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../models/user_profile.dart';
import '../services/hive_service.dart';
import 'profile_repository.dart';

class HybridProfileRepository implements ProfileRepository {
  HybridProfileRepository({required this.hiveService})
      : _streamController = StreamController<UserProfile?>.broadcast();

  final HiveService hiveService;
  final StreamController<UserProfile?> _streamController;
  final Map<String, UserProfile> _memoryCache = <String, UserProfile>{};

  bool get _isFirebaseActive {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  FirebaseFirestore? get _firestore {
    if (!_isFirebaseActive) return null;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<UserProfile?> getProfile(String uid) async {
    if (_memoryCache.containsKey(uid)) {
      return _memoryCache[uid];
    }

    final FirebaseFirestore? fs = _firestore;
    if (fs != null) {
      try {
        final DocumentSnapshot<Map<String, dynamic>> doc =
            await fs.collection('users').doc(uid).get();
        if (doc.exists && doc.data() != null) {
          final UserProfile profile = UserProfile.fromJson(doc.data()!);
          _cacheLocally(profile);
          return profile;
        }
      } catch (e) {
        debugPrint('Firestore fetch profile failed, using local fallback: $e');
      }
    }

    return _readLocalProfile(uid);
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    final UserProfile updated = profile.copyWith(
      updatedAt: DateTime.now(),
      createdAt: profile.createdAt ?? DateTime.now(),
    );

    _cacheLocally(updated);
    _streamController.add(updated);

    final FirebaseFirestore? fs = _firestore;
    if (fs != null) {
      try {
        await fs
            .collection('users')
            .doc(updated.uid)
            .set(updated.toJson(), SetOptions(merge: true));
      } catch (e) {
        debugPrint('Firestore save profile warning: $e');
      }
    }
  }

  @override
  Stream<UserProfile?> watchProfile(String uid) async* {
    final UserProfile? initial = await getProfile(uid);
    yield initial;

    yield* _streamController.stream.where((p) => p?.uid == uid);
  }

  void _cacheLocally(UserProfile profile) {
    _memoryCache[profile.uid] = profile;
    final String key = 'profile_${profile.uid}';
    final String jsonStr = jsonEncode(profile.toJson());
    hiveService.writeString(key, jsonStr);
  }

  UserProfile? _readLocalProfile(String uid) {
    final String key = 'profile_$uid';
    final String? jsonStr = hiveService.readString(key);
    if (jsonStr == null || jsonStr.isEmpty) return null;

    try {
      final Map<String, dynamic> data =
          jsonDecode(jsonStr) as Map<String, dynamic>;
      final UserProfile profile = UserProfile.fromJson(data);
      _memoryCache[uid] = profile;
      return profile;
    } catch (_) {
      return null;
    }
  }
}
