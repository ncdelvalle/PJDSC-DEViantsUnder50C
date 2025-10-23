
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserAuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance; 

  User? _user;              // Holds the currently signed-in user
  bool _isLoading = true;   // Indicates whether the auth state is still loading
  User? get user => _user;
  bool get isLoading => _isLoading;

  // Initializes the user state listener
  UserAuthProvider() {
    _initUser();
  }

  // Listens for auth state changes and updates the user and loading state
  void _initUser() {
    _auth.authStateChanges().listen((user) {
      _user = user;   // Set the current user
      _isLoading = false; // Mark loading as complete
      notifyListeners();
    });
  }

  // Sign in method using email and password
  // Returns null on success, or an error message on failure
  Future<String?> signIn({required String email, required String password}) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = credential.user; 
      notifyListeners();   
      return null;        
    } on FirebaseAuthException catch (e) {
      return e.message;     
    }
  }

  // Sign up method to register a new user
  // Returns null on success, or an error message on failure
  Future<String?> signUp({
    required String email,
    required String password,
    required String firstName, 
    required String lastName, 
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = credential.user;  // Set the newly created user
      notifyListeners();    
      return null;              // Sign-up successful
    } on FirebaseAuthException catch (e) {
      return e.message;  // Else return error message
    }
  }

  // Signs the user out and clears the user state
  Future<void> signOut() async {
    await _auth.signOut();  // Firebase sign-out
    _user = null; // Clear local user state
    notifyListeners();  
  }
}
