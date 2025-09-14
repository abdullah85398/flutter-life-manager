import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

/// Exception types for better error handling
class AuthException implements Exception {
  final String message;
  final String code;
  
  const AuthException(this.message, this.code);
  
  @override
  String toString() => 'AuthException: $message ($code)';
}

/// Comprehensive authentication service for LifeManager
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  /// Current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  /// Current user
  User? get currentUser => _auth.currentUser;
  
  /// Check if user is signed in
  bool get isSignedIn => currentUser != null;

  // MARK: - Email/Password Authentication

  /// Sign up with email and password
  static Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update display name
      await credential.user?.updateDisplayName(displayName);
      
      // Create user profile in Firestore
      if (credential.user != null) {
        await _createUserProfile(credential.user!, displayName);
      }
      
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw AuthException('An unexpected error occurred', 'unknown');
    }
  }

  /// Sign in with email and password
  static Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw AuthException('An unexpected error occurred', 'unknown');
    }
  }

  /// Sign out
  static Future<void> signOut() async {
    try {
      await Future.wait([
        FirebaseAuth.instance.signOut(),
        GoogleSignIn().signOut(),
      ]);
    } catch (e) {
      throw AuthException('Failed to sign out', 'sign-out-failed');
    }
  }

  /// Delete account
  static Future<void> deleteAccount() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Delete user data from Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .delete();
        
        // Delete Firebase Auth account
        await user.delete();
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw AuthException('Failed to delete account', 'delete-failed');
    }
  }

  // MARK: - Google Sign In

  /// Sign in with Google
  static Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      
      if (googleUser == null) {
        throw AuthException('Google sign in was cancelled', 'cancelled');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      
      // Create user profile if new user
      if (userCredential.additionalUserInfo?.isNewUser == true && userCredential.user != null) {
        await _createUserProfile(
          userCredential.user!,
          userCredential.user!.displayName ?? 'User',
        );
      }
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw AuthException('Google sign in failed', 'google-signin-failed');
    }
  }

  // MARK: - Apple Sign In

  /// Sign in with Apple (iOS only)
  static Future<UserCredential> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(oauthCredential);
      
      // Create user profile if new user
      if (userCredential.additionalUserInfo?.isNewUser == true && userCredential.user != null) {
        final displayName = appleCredential.givenName != null && appleCredential.familyName != null
            ? '${appleCredential.givenName} ${appleCredential.familyName}'
            : 'User';
        
        await _createUserProfile(userCredential.user!, displayName);
      }
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw AuthException('Apple sign in failed', 'apple-signin-failed');
    }
  }

  // MARK: - Password Reset

  /// Send password reset email
  static Future<void> sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw AuthException('Failed to send password reset email', 'reset-failed');
    }
  }

  // MARK: - Helper Methods

  /// Create user profile in Firestore
  static Future<void> _createUserProfile(User user, String displayName) async {
    final userModel = UserModel.create(
      id: user.uid,
      email: user.email ?? '',
      displayName: displayName,
      photoURL: user.photoURL,
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set(userModel.toJson());
  }

  /// Handle Firebase Auth exceptions
  static AuthException _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return const AuthException('No user found with this email', 'user-not-found');
      case 'wrong-password':
        return const AuthException('Incorrect password', 'wrong-password');
      case 'email-already-in-use':
        return const AuthException('An account already exists with this email', 'email-already-in-use');
      case 'weak-password':
        return const AuthException('Password is too weak', 'weak-password');
      case 'invalid-email':
        return const AuthException('Invalid email address', 'invalid-email');
      case 'user-disabled':
        return const AuthException('This account has been disabled', 'user-disabled');
      case 'too-many-requests':
        return const AuthException('Too many failed attempts. Please try again later', 'too-many-requests');
      case 'operation-not-allowed':
        return const AuthException('This sign-in method is not enabled', 'operation-not-allowed');
      case 'requires-recent-login':
        return const AuthException('Please sign in again to continue', 'requires-recent-login');
      default:
        return AuthException(e.message ?? 'Authentication failed', e.code);
    }
  }
}