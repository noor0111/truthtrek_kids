// auth_service.dart
// This service handles signing in and signing out.
// We use Anonymous sign-in — no name, no email, no personal info.

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {

  // _auth is our connection to Firebase Authentication
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Returns the current user (or null if nobody is signed in)
  User? get currentUser => _auth.currentUser;

  // Returns just the user's ID string (a random anonymous ID)
  String? get userId => _auth.currentUser?.uid;

  // Returns true if someone is already signed in
  bool get isSignedIn => _auth.currentUser != null;

  // Signs in anonymously — called once when the app starts
  Future<User?> signInAnonymously() async {
    try {
      // Ask Firebase to create an anonymous account
      final UserCredential result = await _auth.signInAnonymously();
      return result.user;
    } catch (e) {
      // If sign-in fails, print the error and return null
      print('Sign-in failed: $e');
      return null;
    }
  }

  // Deletes the account completely — called from Parent Dashboard
  Future<void> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
    } catch (e) {
      print('Account deletion failed: $e');
      rethrow;
    }
  }
}