import 'package:flutter/foundation.dart';

@immutable
class UserProfile {
  const UserProfile({
    required this.uid,
    required this.fullName,
    required this.collegeName,
    required this.major,
    required this.academicYear,
    this.targetGpa = 3.8,
    this.bio = '',
    this.isProfileComplete = false,
    this.createdAt,
    this.updatedAt,
  });

  final String uid;
  final String fullName;
  final String collegeName;
  final String major;
  final String academicYear; // e.g., 'Freshman', 'Sophomore', 'Junior', 'Senior', 'Graduate'
  final double targetGpa;
  final String bio;
  final bool isProfileComplete;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory UserProfile.empty(String uid) {
    return UserProfile(
      uid: uid,
      fullName: '',
      collegeName: '',
      major: '',
      academicYear: 'Freshman',
      targetGpa: 3.8,
      bio: '',
      isProfileComplete: false,
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'] as String,
      fullName: json['fullName'] as String? ?? '',
      collegeName: json['collegeName'] as String? ?? '',
      major: json['major'] as String? ?? '',
      academicYear: json['academicYear'] as String? ?? 'Freshman',
      targetGpa: (json['targetGpa'] as num?)?.toDouble() ?? 3.8,
      bio: json['bio'] as String? ?? '',
      isProfileComplete: json['isProfileComplete'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'uid': uid,
      'fullName': fullName,
      'collegeName': collegeName,
      'major': major,
      'academicYear': academicYear,
      'targetGpa': targetGpa,
      'bio': bio,
      'isProfileComplete': isProfileComplete,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? uid,
    String? fullName,
    String? collegeName,
    String? major,
    String? academicYear,
    double? targetGpa,
    String? bio,
    bool? isProfileComplete,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      collegeName: collegeName ?? this.collegeName,
      major: major ?? this.major,
      academicYear: academicYear ?? this.academicYear,
      targetGpa: targetGpa ?? this.targetGpa,
      bio: bio ?? this.bio,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          fullName == other.fullName &&
          collegeName == other.collegeName &&
          major == other.major &&
          academicYear == other.academicYear &&
          targetGpa == other.targetGpa &&
          bio == other.bio &&
          isProfileComplete == other.isProfileComplete;

  @override
  int get hashCode =>
      uid.hashCode ^
      fullName.hashCode ^
      collegeName.hashCode ^
      major.hashCode ^
      academicYear.hashCode ^
      targetGpa.hashCode ^
      bio.hashCode ^
      isProfileComplete.hashCode;

  @override
  String toString() {
    return 'UserProfile(uid: $uid, fullName: $fullName, collegeName: $collegeName, major: $major, isProfileComplete: $isProfileComplete)';
  }
}
