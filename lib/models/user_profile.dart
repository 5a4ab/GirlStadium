import 'package:cloud_firestore/cloud_firestore.dart';

// A user's Firestore profile document at users/{uid}, kept in sync with
// their Firebase Authentication identity. Deliberately minimal - only
// the fields ProfileScreen actually shows today.
class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final String providerId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.providerId,
    this.createdAt,
    this.updatedAt,
  });

  // Firestore may legitimately be missing name/email/providerId for a
  // brand-new document still being written, so every field falls back
  // to something safe rather than throwing.
  factory UserProfile.fromFirestore(String uid, Map<String, dynamic> data) {
    final name = (data['name'] as String?)?.trim();
    return UserProfile(
      uid: uid,
      name: (name == null || name.isEmpty) ? 'GirlStadium User' : name,
      email: (data['email'] as String?) ?? '',
      photoUrl: data['photoUrl'] as String?,
      providerId: (data['providerId'] as String?) ?? 'password',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  // A friendly label for the stored providerId, for UI display only -
  // the real value is still what's persisted/compared elsewhere.
  String get providerLabel {
    switch (providerId) {
      case 'google.com':
        return 'Google';
      case 'password':
        return 'Email & Password';
      default:
        return 'Email & Password';
    }
  }
}
