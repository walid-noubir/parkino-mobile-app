import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirebaseAuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? _user;
  String? _errorMessage;
  bool _isLoading = false;

  // Getters
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  FirebaseAuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  /// Sign up with email and password
  Future<bool> signUp({
    required String email,
    required String password,
    required String username,
    required String phone,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Create user account
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('✅ User created in Auth: ${userCredential.user?.email}');

      // Update user profile with username
      await userCredential.user?.updateDisplayName(username);
      
      // Create user document in Firestore
      try {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'email': email,
          'username': username,
          'displayName': username,
          'phone': phone,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        print('✅ User document created in Firestore with phone: $phone');
      } catch (firestoreError) {
        print('❌ Firestore error: $firestoreError');
        // Si Firestore échoue, on supprime l'utilisateur créé à la place
        await userCredential.user?.delete();
        _errorMessage = 'Failed to save user data. Please try again.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      _user = userCredential.user;
      _isLoading = false;
      notifyListeners();
      
      print('✅ User signed up successfully: ${_user?.email}');
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      print('❌ Sign up error: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      print('❌ Unexpected error: $e');
      return false;
    }
  }

  /// Sign in with email and password
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _user = userCredential.user;
      _isLoading = false;
      notifyListeners();
      
      print('✅ User signed in successfully: ${_user?.email}');
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      print('❌ Sign in error: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      print('❌ Unexpected error: $e');
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _user = null;
      _errorMessage = null;
      notifyListeners();
      print('✅ User signed out');
    } catch (e) {
      _errorMessage = 'Error signing out';
      print('❌ Sign out error: $e');
    }
  }

  /// Get error message based on Firebase error code
  String _getErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists with that email address.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'user-disabled':
        return 'The user account has been disabled.';
      case 'user-not-found':
        return 'No account found with that email address.';
      case 'wrong-password':
        return 'The password is incorrect.';
      case 'invalid-credential':
        return 'The email or password is incorrect.';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
