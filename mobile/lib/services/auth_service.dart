import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:shared_preferences/shared_preferences.dart';

class HunterUser {
  final String uid;
  final String email;
  final String displayName;
  final String rank;
  final bool isAnonymous;

  HunterUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.rank = 'E-RANK',
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

    if (savedUid != null && savedUid.isNotEmpty) {
      _currentUser = HunterUser(
        uid: savedUid,
        email: savedEmail ?? 'hunter@system.arc',
        displayName: savedName,
        rank: savedRank,
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
        debugPrint("Firebase signIn error, falling back to local storage: $e");
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('hunter_uid', uid);
    await prefs.setString('hunter_email', email);
    await prefs.setString('hunter_name', displayName);

    _currentUser = HunterUser(
      uid: uid,
      email: email,
      displayName: displayName,
      rank: 'E-RANK',
    );

    _authController.add(_currentUser);
    notifyListeners();
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
        debugPrint("Firebase signUp error, falling back to local storage: $e");
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('hunter_uid', uid);
    await prefs.setString('hunter_email', email);
    await prefs.setString('hunter_name', displayName);

    _currentUser = HunterUser(
      uid: uid,
      email: email,
      displayName: displayName,
      rank: 'E-RANK',
    );

    _authController.add(_currentUser);
    notifyListeners();
  }

  Future<void> signInAsGuest([String? guestName]) async {
    final uid = "guest_${DateTime.now().millisecondsSinceEpoch}";
    final name = guestName ?? "Shadow Hunter";

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('hunter_uid', uid);
    await prefs.setString('hunter_email', 'guest@system.solo');
    await prefs.setString('hunter_name', name);

    _currentUser = HunterUser(
      uid: uid,
      email: 'guest@system.solo',
      displayName: name,
      rank: 'E-RANK',
      isAnonymous: true,
    );

    _authController.add(_currentUser);
    notifyListeners();
  }

  Future<void> signOut() async {
    if (_isFirebaseAvailable) {
      try {
        await fb.FirebaseAuth.instance.signOut();
      } catch (_) {}
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('hunter_uid');
    await prefs.remove('hunter_email');
    await prefs.remove('hunter_name');

    _currentUser = null;
    _authController.add(null);
    notifyListeners();
  }
}
