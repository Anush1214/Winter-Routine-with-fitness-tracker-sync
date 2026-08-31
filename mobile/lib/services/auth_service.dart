import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HunterUser {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String rank;
  final String provider;
  final bool isAnonymous;
  final DateTime createdAt;

  HunterUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.rank = 'E-RANK',
    this.provider = 'email',
    this.isAnonymous = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

class AuthException implements Exception {
  final String message;
  final String? code;
  AuthException(this.message, {this.code});

  @override
  String toString() => message;
}

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  HunterUser? _currentUser;
  HunterUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  String get currentUserId => _currentUser?.uid ?? 'default_hunter';

  final StreamController<HunterUser?> _authController =
      StreamController<HunterUser?>.broadcast();
  Stream<HunterUser?> get authStateChanges => _authController.stream;

  bool _isFirebaseAvailable = false;
  bool get isFirebaseAvailable => _isFirebaseAvailable;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  Future<void> init() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        _isFirebaseAvailable = true;
        // Listen to Firebase auth state changes
        fb.FirebaseAuth.instance.authStateChanges().listen((fb.User? user) {
          if (user != null && _currentUser != null) {
            // Sync Firebase state
            _currentUser = HunterUser(
              uid: user.uid,
              email: user.email ?? _currentUser!.email,
              displayName: user.displayName ?? _currentUser!.displayName,
              photoUrl: user.photoURL ?? _currentUser!.photoUrl,
              rank: _currentUser!.rank,
              provider: _currentUser!.provider,
              isAnonymous: user.isAnonymous,
              createdAt: user.metadata.creationTime ?? _currentUser!.createdAt,
            );
            _authController.add(_currentUser);
            notifyListeners();
          }
        });
      }
    } catch (_) {
      _isFirebaseAvailable = false;
    }

    // Restore session from local storage
    final prefs = await SharedPreferences.getInstance();
    final savedUid = prefs.getString('hunter_uid');
    final savedEmail = prefs.getString('hunter_email');
    final savedName = prefs.getString('hunter_name') ?? 'Sung Jin-Woo';
    final savedRank = prefs.getString('hunter_rank') ?? 'E-RANK';
    final savedProvider = prefs.getString('hunter_provider') ?? 'email';
    final savedPhoto = prefs.getString('hunter_photo');
    final savedCreatedAt = prefs.getString('hunter_created_at');

    if (savedUid != null && savedUid.isNotEmpty) {
      _currentUser = HunterUser(
        uid: savedUid,
        email: savedEmail ?? 'hunter@system.arc',
        displayName: savedName,
        photoUrl: savedPhoto,
        rank: savedRank,
        provider: savedProvider,
        createdAt: savedCreatedAt != null
            ? DateTime.tryParse(savedCreatedAt) ?? DateTime.now()
            : DateTime.now(),
      );
      _authController.add(_currentUser);
      notifyListeners();
    }
  }

  /// Email/Password Sign In — requires Firebase
  Future<void> signInWithEmail(String email, String password) async {
    _requireFirebase('Email/Password authentication');

    try {
      final credential = await fb.FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      
      if (credential.user == null) {
        throw AuthException('Sign-in failed: no user returned from Firebase.');
      }

      final user = credential.user!;
      await _saveUserSession(
        uid: user.uid,
        email: user.email ?? email,
        name: user.displayName ?? email.split('@').first.toUpperCase(),
        photoUrl: user.photoURL,
        provider: 'email',
        createdAt: user.metadata.creationTime,
      );
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e.code), code: e.code);
    }
  }

  /// Email/Password Sign Up — requires Firebase
  Future<void> signUpWithEmail(String email, String password, String hunterName) async {
    _requireFirebase('Email/Password registration');

    try {
      final credential = await fb.FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      
      if (credential.user == null) {
        throw AuthException('Registration failed: no user returned from Firebase.');
      }

      final user = credential.user!;
      final displayName = hunterName.isNotEmpty ? hunterName : email.split('@').first;
      await user.updateDisplayName(displayName);

      await _saveUserSession(
        uid: user.uid,
        email: user.email ?? email,
        name: displayName,
        photoUrl: user.photoURL,
        provider: 'email',
        createdAt: user.metadata.creationTime,
      );
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e.code), code: e.code);
    }
  }

  /// Google / Gmail Sign In — works across Web, Android, and iOS
  Future<void> signInWithGoogle() async {
    _requireFirebase('Google Sign-In');

    try {
      fb.UserCredential userCredential;

      if (kIsWeb) {
        // On Web: use standard Firebase Popup flow
        final googleProvider = fb.GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        userCredential = await fb.FirebaseAuth.instance.signInWithPopup(googleProvider);
      } else {
        // On Android / iOS: use native GoogleSignIn plugin
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          throw AuthException('Google Sign-In was cancelled.');
        }

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final fb.AuthCredential credential = fb.GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        userCredential = await fb.FirebaseAuth.instance.signInWithCredential(credential);
      }

      if (userCredential.user == null) {
        throw AuthException('Google Sign-In failed: no user returned from Firebase.');
      }

      final user = userCredential.user!;
      await _saveUserSession(
        uid: user.uid,
        email: user.email ?? 'hunter@gmail.com',
        name: user.displayName ?? 'Google Hunter',
        photoUrl: user.photoURL,
        provider: 'google',
        createdAt: user.metadata.creationTime,
      );
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e.code), code: e.code);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Google Sign-In error: $e');
    }
  }

  /// GitHub Sign In — works across Web, Android, and iOS
  Future<void> signInWithGitHub() async {
    _requireFirebase('GitHub Sign-In');

    try {
      final githubProvider = fb.GithubAuthProvider();
      githubProvider.addScope('read:user');
      githubProvider.addScope('user:email');

      fb.UserCredential userCredential;
      if (kIsWeb) {
        userCredential = await fb.FirebaseAuth.instance.signInWithPopup(githubProvider);
      } else {
        userCredential = await fb.FirebaseAuth.instance.signInWithProvider(githubProvider);
      }

      if (userCredential.user == null) {
        throw AuthException('GitHub Sign-In failed: no user returned from Firebase.');
      }

      final user = userCredential.user!;
      await _saveUserSession(
        uid: user.uid,
        email: user.email ?? 'hunter@github.com',
        name: user.displayName ?? 'GitHub Monarch',
        photoUrl: user.photoURL,
        provider: 'github',
        createdAt: user.metadata.creationTime,
      );
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e.code), code: e.code);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('GitHub Sign-In error: $e');
    }
  }

  /// Guest Mode — no Firebase required
  Future<void> signInAsGuest([String? guestName]) async {
    final uid = "guest_${DateTime.now().millisecondsSinceEpoch}";
    final name = guestName ?? "Shadow Hunter";

    // If Firebase is available, use anonymous auth
    if (_isFirebaseAvailable) {
      try {
        final credential = await fb.FirebaseAuth.instance.signInAnonymously();
        if (credential.user != null) {
          await _saveUserSession(
            uid: credential.user!.uid,
            email: 'guest@winterarc.solo',
            name: name,
            provider: 'guest',
            isAnonymous: true,
            createdAt: credential.user!.metadata.creationTime,
          );
          return;
        }
      } catch (_) {}
    }

    await _saveUserSession(
      uid: uid,
      email: 'guest@winterarc.solo',
      name: name,
      provider: 'guest',
      isAnonymous: true,
    );
  }

  /// Update the hunter's display name
  Future<void> updateDisplayName(String newName) async {
    if (newName.trim().isEmpty) return;

    if (_isFirebaseAvailable && fb.FirebaseAuth.instance.currentUser != null) {
      await fb.FirebaseAuth.instance.currentUser!.updateDisplayName(newName.trim());
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('hunter_name', newName.trim());

    if (_currentUser != null) {
      _currentUser = HunterUser(
        uid: _currentUser!.uid,
        email: _currentUser!.email,
        displayName: newName.trim(),
        photoUrl: _currentUser!.photoUrl,
        rank: _currentUser!.rank,
        provider: _currentUser!.provider,
        isAnonymous: _currentUser!.isAnonymous,
        createdAt: _currentUser!.createdAt,
      );
      _authController.add(_currentUser);
      notifyListeners();
    }
  }

  /// Sign out and clear session
  Future<void> signOut() async {
    if (_isFirebaseAvailable) {
      try {
        await fb.FirebaseAuth.instance.signOut();
        await _googleSignIn.signOut();
      } catch (_) {}
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('hunter_uid');
    await prefs.remove('hunter_email');
    await prefs.remove('hunter_name');
    await prefs.remove('hunter_provider');
    await prefs.remove('hunter_photo');
    await prefs.remove('hunter_rank');
    await prefs.remove('hunter_created_at');

    _currentUser = null;
    _authController.add(null);
    notifyListeners();
  }

  /// Delete the account entirely
  Future<void> deleteAccount() async {
    if (_isFirebaseAvailable && fb.FirebaseAuth.instance.currentUser != null) {
      try {
        await fb.FirebaseAuth.instance.currentUser!.delete();
      } on fb.FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          throw AuthException(
            'For security, please sign out and sign back in before deleting your account.',
            code: e.code,
          );
        }
        rethrow;
      }
    }
    await signOut();
  }

  // ─── Private Helpers ───────────────────────────────────

  void _requireFirebase(String feature) {
    if (!_isFirebaseAvailable) {
      throw AuthException(
        '$feature requires Firebase. Please configure Firebase:\n'
        '1. Place google-services.json in android/app/\n'
        '2. Run: flutterfire configure',
      );
    }
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No hunter found with this email. Register first.';
      case 'wrong-password':
        return 'Invalid password. Try again.';
      case 'invalid-email':
        return 'Invalid email format.';
      case 'user-disabled':
        return 'This hunter account has been suspended.';
      case 'email-already-in-use':
        return 'This email is already registered. Sign in instead.';
      case 'weak-password':
        return 'Password too weak. Use at least 6 characters.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled in Firebase Console.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different provider for this email.';
      case 'invalid-credential':
        return 'Invalid credentials. Please try again.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return 'Authentication error: $code';
    }
  }

  Future<void> _saveUserSession({
    required String uid,
    required String email,
    required String name,
    required String provider,
    String? photoUrl,
    bool isAnonymous = false,
    DateTime? createdAt,
  }) async {
    final now = createdAt ?? DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('hunter_uid', uid);
    await prefs.setString('hunter_email', email);
    await prefs.setString('hunter_name', name);
    await prefs.setString('hunter_provider', provider);
    await prefs.setString('hunter_created_at', now.toIso8601String());
    if (photoUrl != null) {
      await prefs.setString('hunter_photo', photoUrl);
    }

    _currentUser = HunterUser(
      uid: uid,
      email: email,
      displayName: name,
      photoUrl: photoUrl,
      rank: 'E-RANK',
      provider: provider,
      isAnonymous: isAnonymous,
      createdAt: now,
    );

    _authController.add(_currentUser);
    notifyListeners();
  }
}
