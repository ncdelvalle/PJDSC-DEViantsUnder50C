import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthAPI {
  static final FirebaseAuth auth = FirebaseAuth.instance;
  UserCredential? credential;

  Stream<User?> getUserStream() {
    return auth.authStateChanges(); 
  }

  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      // Attempt to sign in with email and password
      credential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential!;
    } on FirebaseAuthException catch (e) {
      // Handle authentication exceptions
      if (e.code == 'user-not-found') {
        throw Exception('User not found');
      } else if (e.code == 'wrong-password') {
        throw Exception('Wrong password');
      } else {
        throw Exception('Authentication failed: ${e.message}');
      }
    }
  }

  // Sign out
  Future<void> signOut() async {
    await auth.signOut();
  }
}
