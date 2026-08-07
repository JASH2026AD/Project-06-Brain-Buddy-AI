import '../models/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile?> getProfile(String uid);
  Future<void> saveProfile(UserProfile profile);
  Stream<UserProfile?> watchProfile(String uid);
}
