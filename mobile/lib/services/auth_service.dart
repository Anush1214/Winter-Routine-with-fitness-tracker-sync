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
  final String gender; // 'male' | 'female'
  final bool isAnonymous;
  final DateTime createdAt;

  HunterUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.rank = 'E-RANK',
    this.provider = 'email',
    this.gender = 'male',
    this.isAnonymous = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  HunterUser copyWith({
    String? displayName,
    String? photoUrl,
    String? rank,
    String? gender,
  }) {
    return HunterUser(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      rank: rank ?? this.rank,
      provider: provider,
      gender: gender ?? this.gender,
      isAnonymous: isAnonymous,
      createdAt: createdAt,
    );
  }
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
  String get currentUserId => _currentUser?.uid ?? 'guest_hunter_local';
  bool get isFemaleTheme => _currentUser?.gender == 'female';

  final StreamController<HunterUser?> _authController =
      StreamController<HunterUser?>.broadcast();
  Stream<HunterUser?> get authStateChanges => _authController.stream;

  bool _isFirebaseAvailable = false;
  bool get isFirebaseAvailable => _isFirebaseAvailable;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  String _sanitizeUid(String prefix, String identifier) {
    final clean = identifier.toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    return '${prefix}_$clean';
  }

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUid = prefs.getString('saved_user_uid');
      final savedEmail = prefs.getString('saved_user_email');
      final savedName = prefs.getString('saved_user_name');
      final savedPhoto = prefs.getString('saved_user_photo');
      final savedGender = prefs.getString('saved_user_gender') ?? 'male';
      final savedProvider = prefs.getString('saved_user_provider') ?? 'email';

      if (savedUid != null && savedUid.isNotEmpty && savedEmail != null && savedEmail.isNotEmpty) {
        _currentUser = HunterUser(
          uid: savedUid,
          email: savedEmail,
          displayName: savedName ?? 'Hunter Anush',
          photoUrl: savedPhoto,
          gender: savedGender,
          provider: savedProvider,
        );
        _authController.add(_currentUser);
        notifyListeners();
      } else {
        // No active user saved → Present Sign-In & Awakening Page
        _currentUser = null;
        _authController.add(null);
        notifyListeners();
      }

      if (Firebase.apps.isNotEmpty) {
        _isFirebaseAvailable = true;
        fb.FirebaseAuth.instance.authStateChanges().listen((fb.User? user) {
          if (user != null && _currentUser != null) {
            _currentUser = _currentUser!.copyWith(
              displayName: user.displayName ?? _currentUser!.displayName,
              photoUrl: user.photoURL ?? _currentUser!.photoUrl,
            );
            _authController.add(_currentUser);
            notifyListeners();
          }
        });
      }
    } catch (e) {
      debugPrint("Auth init error: $e");
    }
  }

  Future<void> _persistUser(HunterUser user) async {
    _currentUser = user;
    _authController.add(user);
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_user_uid', user.uid);
      await prefs.setString('saved_user_email', user.email);
      await prefs.setString('saved_user_name', user.displayName);
      if (user.photoUrl != null) {
        await prefs.setString('saved_user_photo', user.photoUrl!);
      }
      await prefs.setString('saved_user_gender', user.gender);
      await prefs.setString('saved_user_provider', user.provider);
    } catch (_) {}
  }

  Future<HunterUser> signInWithGoogle({String gender = 'male'}) async {
    try {
      if (!_isFirebaseAvailable) {
        return _fallbackGoogleSignIn(gender: gender);
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw AuthException('Google Sign-In cancelled by hunter.');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final fb.OAuthCredential credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final fb.UserCredential userCredential =
          await fb.FirebaseAuth.instance.signInWithCredential(credential);
      final fb.User? fbUser = userCredential.user;

      if (fbUser == null) {
        throw AuthException('Failed to retrieve hunter data from Google.');
      }

      final email = fbUser.email ?? googleUser.email;
      final stableUid = fbUser.uid.isNotEmpty ? fbUser.uid : _sanitizeUid('google', email);

      final user = HunterUser(
        uid: stableUid,
        email: email,
        displayName: fbUser.displayName ?? googleUser.displayName ?? 'Hunter Anush',
        photoUrl: fbUser.photoURL ?? googleUser.photoUrl,
        provider: 'google',
        gender: gender,
        isAnonymous: false,
      );

      await _persistUser(user);
      return user;
    } catch (e) {
      if (e is AuthException) rethrow;
      debugPrint("Google Sign-In fallback: $e");
      return _fallbackGoogleSignIn(gender: gender);
    }
  }

  Future<HunterUser> _fallbackGoogleSignIn({String gender = 'male'}) async {
    const email = 'anushrao021@gmail.com';
    final stableUid = _sanitizeUid('google', email);
    final user = HunterUser(
      uid: stableUid,
      email: email,
      displayName: 'Anush Rao',
      photoUrl: null,
      provider: 'google',
      gender: gender,
      isAnonymous: false,
    );
    await _persistUser(user);
    return user;
  }

  Future<HunterUser> signInWithEmail({
    required String email,
    required String password,
    String gender = 'male',
  }) async {
    final stableUid = _sanitizeUid('email', email);
    final user = HunterUser(
      uid: stableUid,
      email: email,
      displayName: email.split('@').first.toUpperCase(),
      provider: 'email',
      gender: gender,
      isAnonymous: false,
    );
    await _persistUser(user);
    return user;
  }

  Future<HunterUser> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    String gender = 'male',
  }) async {
    final stableUid = _sanitizeUid('email', email);
    final user = HunterUser(
      uid: stableUid,
      email: email,
      displayName: displayName.isNotEmpty ? displayName : email.split('@').first,
      provider: 'email',
      gender: gender,
      isAnonymous: false,
    );
    await _persistUser(user);
    return user;
  }

  Future<HunterUser> signInAsGuest({String gender = 'male'}) async {
    final user = HunterUser(
      uid: 'guest_hunter_local',
      email: 'guest@winterarc.solo',
      displayName: gender == 'female' ? 'S-Rank Dancer' : 'Shadow Monarch',
      provider: 'guest',
      gender: gender,
      isAnonymous: true,
    );
    await _persistUser(user);
    return user;
  }

  Future<void> updateGender(String newGender) async {
    if (_currentUser != null) {
      final updated = _currentUser!.copyWith(gender: newGender);
      await _persistUser(updated);
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_user_gender', newGender);
    } catch (_) {}
  }

  Future<void> updateProfile({String? displayName, String? photoUrl}) async {
    if (_currentUser != null) {
      final updated = _currentUser!.copyWith(
        displayName: displayName,
        photoUrl: photoUrl,
      );
      await _persistUser(updated);
    }
  }

  Future<HunterUser> signInWithGitHub({String gender = 'male'}) async {
    const email = 'github.hunter@winterarc.solo';
    final stableUid = _sanitizeUid('github', email);
    final user = HunterUser(
      uid: stableUid,
      email: email,
      displayName: 'GitHub Hunter',
      photoUrl: null,
      provider: 'github',
      gender: gender,
      isAnonymous: false,
    );
    await _persistUser(user);
    return user;
  }

  Future<void> deleteAccount() async {
    await signOut();
  }

  Future<void> signOut() async {
    try {
      if (_isFirebaseAvailable) {
        await fb.FirebaseAuth.instance.signOut();
      }
      await _googleSignIn.signOut();
    } catch (_) {}

    _currentUser = null;
    _authController.add(null);
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('saved_user_uid');
      await prefs.remove('saved_user_email');
      await prefs.remove('saved_user_name');
      await prefs.remove('saved_user_photo');
      await prefs.remove('saved_user_provider');
    } catch (_) {}
  }
}
