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
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD04ghGXwI8-lbdNguePrY00lFDHCpCBuI',
    appId: '1:8201560727:web:6543210fedcba987', // Note: Placeholder, get actual from Firebase Console
    messagingSenderId: '8201560727',
    projectId: 'section-two-supermarket',
    authDomain: 'section-two-supermarket.firebaseapp.com',
    storageBucket: 'section-two-supermarket.firebasestorage.app',
    measurementId: 'G-XXXXXXXXXX',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD04ghGXwI8-lbdNguePrY00lFDHCpCBuI',
    appId: '1:8201560727:android:07c840e4a05c286432bfd2',
    messagingSenderId: '8201560727',
    projectId: 'section-two-supermarket',
    storageBucket: 'section-two-supermarket.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD04ghGXwI8-lbdNguePrY00lFDHCpCBuI',
    appId: '1:8201560727:ios:abcdef1234567890', // Note: Get actual iOS App ID from Firebase Console
    messagingSenderId: '8201560727',
    projectId: 'section-two-supermarket',
    storageBucket: 'section-two-supermarket.firebasestorage.app',
    iosBundleId: 'com.example.section_two_supermarket',
  );
}
