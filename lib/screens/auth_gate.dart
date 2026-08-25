import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/user_profile_service.dart';
import '../theme/app_colors.dart';
import 'intro_screen.dart';
import 'navigation_screen.dart';

// The single source of truth for whether the app shows signed-out or
// signed-in UI. Sits below Splash and reacts automatically whenever
// Firebase's auth state changes - no manual booleans, no navigation calls
// of its own.
//
// This is also the one place that ensures a signed-in user's Firestore
// profile exists/is synced: authStateChanges() fires after email
// sign-up, email sign-in, Google sign-in, AND on a persisted session at
// launch, so hooking in here covers every case without duplicating any
// Firebase Authentication calls.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  // Guards against re-syncing on every rebuild: only the first time a
  // given UID is seen as signed-in triggers a Firestore write.
  String? _syncedUid;

  void _syncProfileIfNeeded(User user) {
    if (_syncedUid == user.uid) return;
    _syncedUid = user.uid;
    // Fire-and-forget - a temporary Firestore/network failure must
    // never block or undo a successful Firebase Auth sign-in.
    // ProfileScreen has its own error/retry state if this never
    // succeeds.
    // ignore: unawaited_futures
    UserProfileService.instance.ensureProfileSynced(user).catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.deepBackground,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.accentPink),
            ),
          );
        }

        final user = snapshot.data;
        if (user != null) {
          _syncProfileIfNeeded(user);
          return const NavigationScreen();
        }

        _syncedUid = null;
        return const IntroScreen();
      },
    );
  }
}
