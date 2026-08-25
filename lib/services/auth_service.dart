import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Centralizes all Firebase Authentication + Google Sign-In calls behind a
// simple singleton, so screens never talk to FirebaseAuth/GoogleSignIn
// directly. No extra state-management package involved.
class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // GoogleSignIn.instance.initialize() must be called exactly once before
  // any other GoogleSignIn method is used. Caching the future (rather than
  // a bool) means concurrent callers all await the same initialization
  // instead of racing to call initialize() twice.
  Future<void>? _googleSignInInitialization;

  Future<void> _ensureGoogleSignInInitialized() {
    return _googleSignInInitialization ??= _googleSignIn.initialize();
  }

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    // Store the display name on the Firebase Auth user profile itself -
    // not a Firestore document, which is out of scope for this milestone.
    await credential.user?.updateDisplayName(name.trim());
    return credential;
  }

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> signInWithGoogle() async {
    await _ensureGoogleSignInInitialized();
    final account = await _googleSignIn.authenticate();
    final idToken = account.authentication.idToken;
    final credential = GoogleAuthProvider.credential(idToken: idToken);
    return _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await _ensureGoogleSignInInitialized();
    // signOut() ends the local session without revoking the app's Google
    // authorization - disconnect() is for the rarer "revoke access"
    // case and is intentionally not used for an ordinary logout.
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}

// Maps FirebaseAuthException codes to short, user-friendly messages so raw
// exception text never reaches the UI. Modern Firebase often returns
// invalid-credential instead of revealing whether the email or password
// was wrong, so that (and the legacy codes) share one safe message.
String authErrorMessage(Object error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'invalid-email':
        return 'That email address looks invalid.';
      case 'invalid-credential':
      case 'user-not-found':
      case 'wrong-password':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists with that email.';
      case 'weak-password':
        return 'Please choose a stronger password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return "Network error. Check your connection and try again.";
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'user-disabled':
        return 'This account has been disabled.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
  return 'Something went wrong. Please try again.';
}
