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

  // Web Client ID used for Google Sign In token verification across platforms
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '37819138819-5ntotmdejvs65uscip3pgh39coh4ldh0.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  Future<void> init() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        _isFirebaseAvailable = true;
        fb.FirebaseAuth.instance.authStateChanges().listen((fb.User? user) {
          if (user != null && _currentUser != null) {
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

  /// Email/Password Sign In
  Future<void> signInWithEmail(String email, String password) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      throw AuthException('Please enter both email and password.');
    }

    String uid = "hunter_${email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}";
    String displayName = email.split('@').first.toUpperCase();
    String? photoUrl;

    if (_isFirebaseAvailable) {
      try {
        final credential = await fb.FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email.trim(), password: password.trim());
        if (credential.user != null) {
          uid = credential.user!.uid;
          displayName = credential.user!.displayName ?? displayName;
          photoUrl = credential.user!.photoURL;
        }
      } on fb.FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
          throw AuthException('Invalid email identifier or security key.', code: e.code);
        } else if (e.code == 'invalid-email') {
          throw AuthException('Invalid email address format.', code: e.code);
        } else if (e.code == 'user-disabled') {
          throw AuthException('This hunter account has been disabled.', code: e.code);
        } else {
          debugPrint("Firebase email sign in note: ${e.message}");
        }
      }
    }

    await _saveUserSession(
      uid: uid,
      email: email.trim(),
      name: displayName,
      photoUrl: photoUrl,
      provider: 'email',
    );
  }

  /// Email/Password Sign Up
  Future<void> signUpWithEmail(String email, String password, String hunterName) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      throw AuthException('Please enter both email and password.');
    }
    if (password.trim().length < 6) {
      throw AuthException('Password must be at least 6 characters.');
    }

    String uid = "hunter_${email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}";
    final displayName = hunterName.trim().isNotEmpty ? hunterName.trim() : email.split('@').first.toUpperCase();
    String? photoUrl;

    if (_isFirebaseAvailable) {
      try {
        final credential = await fb.FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email.trim(), password: password.trim());
        if (credential.user != null) {
          uid = credential.user!.uid;
          await credential.user!.updateDisplayName(displayName);
          photoUrl = credential.user!.photoURL;
        }
      } on fb.FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          throw AuthException('This email is already registered. Switch to Hunter Sign In.', code: e.code);
        } else if (e.code == 'weak-password') {
          throw AuthException('Password is too weak. Choose at least 6 characters.', code: e.code);
        } else {
          debugPrint("Firebase sign up note: ${e.message}");
        }
      }
    }

    await _saveUserSession(
      uid: uid,
      email: email.trim(),
      name: displayName,
      photoUrl: photoUrl,
      provider: 'email',
    );
  }

  /// Google / Gmail Sign In (Strict — Never auto-creates guest accounts)
  Future<void> signInWithGoogle() async {
    if (kIsWeb) {
      final googleProvider = fb.GoogleAuthProvider();
      googleProvider.addScope('email');
      googleProvider.addScope('profile');
      try {
        final userCredential = await fb.FirebaseAuth.instance.signInWithPopup(googleProvider);
        if (userCredential.user != null) {
          final user = userCredential.user!;
          await _saveUserSession(
            uid: user.uid,
            email: user.email ?? 'hunter@gmail.com',
            name: user.displayName ?? 'Google Hunter',
            photoUrl: user.photoURL,
            provider: 'google',
            createdAt: user.metadata.creationTime,
          );
        }
      } catch (e) {
        throw AuthException('Google Sign-In failed on web: $e');
      }
      return;
    }

    // Native Mobile Google Sign In with Adaptive Fallback
    GoogleSignInAccount? googleUser;
    try {
      googleUser = await _googleSignIn.signIn();
    } catch (e) {
      debugPrint("Primary Google Sign-In error: $e, attempting standard native fallback...");
      try {
        final fallbackGoogleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
        googleUser = await fallbackGoogleSignIn.signIn();
      } catch (fallbackError) {
        debugPrint("Fallback Google Sign-In error: $fallbackError");
        throw AuthException('Google Sign-In failed ($e). Please verify Support Email and SHA-1 in Firebase Console.');
      }
    }

    if (googleUser == null) {
      // User dismissed the Google dialog — stay on screen cleanly
      return;
    }

    String uid = "google_${googleUser.id}";
    String email = googleUser.email;
    String displayName = googleUser.displayName ?? 'Google Hunter';
    String? photoUrl = googleUser.photoUrl;

    // Exchange with Firebase credentials if available
    if (_isFirebaseAvailable) {
      try {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        if (googleAuth.idToken != null || googleAuth.accessToken != null) {
          final fb.AuthCredential credential = fb.GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          final userCredential = await fb.FirebaseAuth.instance.signInWithCredential(credential);
          if (userCredential.user != null) {
            uid = userCredential.user!.uid;
            email = userCredential.user!.email ?? email;
            displayName = userCredential.user!.displayName ?? displayName;
            photoUrl = userCredential.user!.photoURL ?? photoUrl;
          }
        }
      } catch (e) {
        debugPrint("Firebase credential token exchange note: $e");
      }
    }

    await _saveUserSession(
      uid: uid,
      email: email,
      name: displayName,
      photoUrl: photoUrl,
      provider: 'google',
    );
  }

  /// GitHub Sign In (Strict — Never auto-creates guest accounts)
  Future<void> signInWithGitHub() async {
    if (kIsWeb && _isFirebaseAvailable) {
      try {
        final githubProvider = fb.GithubAuthProvider();
        githubProvider.addScope('read:user');
        githubProvider.addScope('user:email');
        final userCredential = await fb.FirebaseAuth.instance.signInWithPopup(githubProvider);

        if (userCredential.user != null) {
          final user = userCredential.user!;
          await _saveUserSession(
            uid: user.uid,
            email: user.email ?? 'hunter@github.com',
            name: user.displayName ?? 'GitHub Monarch',
            photoUrl: user.photoURL,
            provider: 'github',
            createdAt: user.metadata.creationTime,
          );
          return;
        }
      } catch (e) {
        throw AuthException('GitHub Sign-In failed: $e');
      }
    } else if (_isFirebaseAvailable) {
      try {
        final githubProvider = fb.GithubAuthProvider();
        final userCredential = await fb.FirebaseAuth.instance.signInWithProvider(githubProvider);
        if (userCredential.user != null) {
          final user = userCredential.user!;
          await _saveUserSession(
            uid: user.uid,
            email: user.email ?? 'hunter@github.com',
            name: user.displayName ?? 'GitHub Monarch',
            photoUrl: user.photoURL,
            provider: 'github',
            createdAt: user.metadata.creationTime,
          );
          return;
        }
      } catch (e) {
        debugPrint("Native GitHub Provider error: $e");
        throw AuthException('GitHub Sign-In error ($e). Make sure GitHub Provider is enabled with Client Secret in Firebase.');
      }
    } else {
      throw AuthException('Firebase is initializing. Please try again.');
    }
  }

  /// Guest Mode — ONLY triggered when user deliberately taps Guest button
  Future<void> signInAsGuest([String? guestName]) async {
    final uid = "guest_${DateTime.now().millisecondsSinceEpoch}";
    final name = guestName ?? "Shadow Hunter";

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

  /// Update display name
  Future<void> updateDisplayName(String newName) async {
    if (newName.trim().isEmpty) return;

    if (_isFirebaseAvailable && fb.FirebaseAuth.instance.currentUser != null) {
      try {
        await fb.FirebaseAuth.instance.currentUser!.updateDisplayName(newName.trim());
      } catch (_) {}
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

  /// Update photo URL
  Future<void> updatePhotoUrl(String newPhotoUrl) async {
    if (newPhotoUrl.trim().isEmpty) return;

    if (_isFirebaseAvailable && fb.FirebaseAuth.instance.currentUser != null) {
      try {
        await fb.FirebaseAuth.instance.currentUser!.updatePhotoURL(newPhotoUrl.trim());
      } catch (_) {}
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('hunter_photo', newPhotoUrl.trim());

    if (_currentUser != null) {
      _currentUser = HunterUser(
        uid: _currentUser!.uid,
        email: _currentUser!.email,
        displayName: _currentUser!.displayName,
        photoUrl: newPhotoUrl.trim(),
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

  /// Delete account
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
      } catch (_) {}
    }
    await signOut();
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
