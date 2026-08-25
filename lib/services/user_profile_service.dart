import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';

// Centralizes all Firestore reads/writes for users/{uid} profile
// documents behind a simple singleton, mirroring AuthService. Screens
// never talk to FirebaseFirestore directly.
class UserProfileService {
  UserProfileService._();

  static final UserProfileService instance = UserProfileService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _profileRef(String uid) {
    return _firestore.collection('users').doc(uid);
  }

  // Creates the Firestore profile for [user] if users/{uid} doesn't
  // exist yet, or refreshes identity fields on an existing one.
  // createdAt is only ever set on first creation - an existing
  // document keeps its original createdAt and only gets a fresh
  // updatedAt plus the latest name/email/photoUrl/providerId.
  Future<void> ensureProfileSynced(User user) async {
    final ref = _profileRef(user.uid);
    final snapshot = await ref.get();

    final providerId = user.providerData.isNotEmpty
        ? user.providerData.first.providerId
        : 'password';
    final name = user.displayName?.trim().isNotEmpty == true
        ? user.displayName!.trim()
        : (user.email ?? 'GirlStadium User');

    if (!snapshot.exists) {
      await ref.set({
        'uid': user.uid,
        'name': name,
        'email': user.email ?? '',
        'photoUrl': user.photoURL,
        'providerId': providerId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return;
    }

    await ref.update({
      'name': name,
      'email': user.email ?? '',
      'photoUrl': user.photoURL,
      'providerId': providerId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Streams the signed-in user's own profile document. Never queries
  // the wider users collection.
  Stream<UserProfile?> watchProfile(String uid) {
    return _profileRef(uid).snapshots().map((snapshot) {
      final data = snapshot.data();
      if (data == null) return null;
      return UserProfile.fromFirestore(uid, data);
    });
  }

  Future<void> updateName(String uid, String name) {
    return _profileRef(uid).update({
      'name': name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
