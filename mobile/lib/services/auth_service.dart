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
  final String rank;
  final String provider;
  final bool isAnonymous;

  HunterUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.rank = 'E-RANK',
    this.provider = 'email',
    this.isAnonymous = false,
  });
}

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  HunterUser? _currentUser;
  HunterUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  final StreamController<HunterUser?> _authController =
      StreamController<HunterUser?>.broadcast();
  Stream<HunterUser?> get authStateChanges => _authController.stream;

  bool _isFirebaseAvailable = false;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  Future<void> init() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        _isFirebaseAvailable = true;
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

    if (savedUid != null && savedUid.isNotEmpty) {
      _currentUser = HunterUser(
        uid: savedUid,
        email: savedEmail ?? 'hunter@system.arc',
        displayName: savedName,
        rank: savedRank,
        provider: savedProvider,
      );
      _authController.add(_currentUser);
      notifyListeners();
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    String uid = "hunter_${email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}";
    String displayName = email.split('@').first.toUpperCase();

    if (_isFirebaseAvailable) {
      try {
        final credential = await fb.FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
        if (credential.user != null) {
          uid = credential.user!.uid;
          displayName = credential.user!.displayName ?? displayName;
        }
      } catch (e) {
        debugPrint("Firebase signIn error: $e");
      }
    }

    await _saveUserSession(uid: uid, email: email, name: displayName, provider: 'email');
  }

  Future<void> signUpWithEmail(
      String email, String password, String hunterName) async {
    String uid = "hunter_${email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}";
    final displayName = hunterName.isNotEmpty ? hunterName : email.split('@').first;

    if (_isFirebaseAvailable) {
      try {
        final credential = await fb.FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        if (credential.user != null) {
          uid = credential.user!.uid;
          await credential.user!.updateDisplayName(displayName);
        }
      } catch (e) {
        debugPrint("Firebase signUp error: $e");
      }
    }

    await _saveUserSession(uid: uid, email: email, name: displayName, provider: 'email');
  }

  /// 🌐 Sign in with Google / Gmail
  Future<void> signInWithGoogle() async {
    String uid = "google_hunter_${DateTime.now().millisecondsSinceEpoch}";
    String email = "hunter@gmail.com";
    String displayName = "Google Hunter";

    try {
      if (!kIsWeb && _isFirebaseAvailable) {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser != null) {
          final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
          final fb.AuthCredential credential = fb.GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );

          final userCredential = await fb.FirebaseAuth.instance.signInWithCredential(credential);
          if (userCredential.user != null) {
            uid = userCredential.user!.uid;
            email = userCredential.user!.email ?? email;
            displayName = userCredential.user!.displayName ?? googleUser.displayName ?? displayName;
          }
        }
      } else {
        // Web / simulated fallback
        email = "hunter.gmail@system.solo";
        displayName = "Shadow Hunter (Google)";
      }
    } catch (e) {
      debugPrint("Google Sign-In fallback: $e");
      email = "hunter.gmail@system.solo";
      displayName = "Shadow Hunter (Google)";
    }

    await _saveUserSession(uid: uid, email: email, name: displayName, provider: 'google');
  }

  /// 🐙 Sign in with GitHub
  Future<void> signInWithGitHub() async {
    String uid = "github_hunter_${DateTime.now().millisecondsSinceEpoch}";
    String email = "hunter@github.com";
    String displayName = "GitHub Monarch";

    try {
      if (_isFirebaseAvailable) {
        final githubProvider = fb.GithubAuthProvider();
        final userCredential = await fb.FirebaseAuth.instance.signInWithProvider(githubProvider);
        if (userCredential.user != null) {
          uid = userCredential.user!.uid;
          email = userCredential.user!.email ?? email;
          displayName = userCredential.user!.displayName ?? displayName;
        }
      } else {
        email = "hunter.github@system.solo";
        displayName = "Monarch of Shadows (GitHub)";
      }
    } catch (e) {
      debugPrint("GitHub Sign-In fallback: $e");
      email = "hunter.github@system.solo";
      displayName = "Monarch of Shadows (GitHub)";
    }

    await _saveUserSession(uid: uid, email: email, name: displayName, provider: 'github');
  }

  Future<void> signInAsGuest([String? guestName]) async {
    final uid = "guest_${DateTime.now().millisecondsSinceEpoch}";
    final name = guestName ?? "Shadow Hunter";

    await _saveUserSession(
      uid: uid,
      email: 'guest@system.solo',
      name: name,
      provider: 'guest',
      isAnonymous: true,
    );
  }

  Future<void> _saveUserSession({
    required String uid,
    required String email,
    required String name,
    required String provider,
    bool isAnonymous = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('hunter_uid', uid);
    await prefs.setString('hunter_email', email);
    await prefs.setString('hunter_name', name);
    await prefs.setString('hunter_provider', provider);

    _currentUser = HunterUser(
      uid: uid,
      email: email,
      displayName: name,
      rank: 'E-RANK',
      provider: provider,
      isAnonymous: isAnonymous,
    );

    _authController.add(_currentUser);
    notifyListeners();
  }

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

    _currentUser = null;
    _authController.add(null);
    notifyListeners();
  }
}
