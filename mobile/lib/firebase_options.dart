// File configured with live credentials for winter-arc-protocol
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC6X1Yfn-sHCGauiznJJYicQmmraTSNdiw',
    appId: '1:37819138819:web:6f5fb1969209b043bb5f36',
    messagingSenderId: '37819138819',
    projectId: 'winter-arc-protocol',
    authDomain: 'winter-arc-protocol.firebaseapp.com',
    storageBucket: 'winter-arc-protocol.firebasestorage.app',
    measurementId: 'G-FJHLL5V1VN',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC6X1Yfn-sHCGauiznJJYicQmmraTSNdiw',
    appId: '1:37819138819:android:a1b2c3d4e5f6g7h8i9j0k1',
    messagingSenderId: '37819138819',
    projectId: 'winter-arc-protocol',
    storageBucket: 'winter-arc-protocol.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC6X1Yfn-sHCGauiznJJYicQmmraTSNdiw',
    appId: '1:37819138819:ios:a1b2c3d4e5f6g7h8i9j0k1',
    messagingSenderId: '37819138819',
    projectId: 'winter-arc-protocol',
    storageBucket: 'winter-arc-protocol.firebasestorage.app',
    iosBundleId: 'com.example.winterArcMobile',
  );
}
