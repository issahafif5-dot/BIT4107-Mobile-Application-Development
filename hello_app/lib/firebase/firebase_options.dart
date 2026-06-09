import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return web;
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDemoKeyUpdateWithYourProjectKey',
    appId: '1:123456789:web:abcdef0123456789abcdef',
    messagingSenderId: '123456789',
    projectId: 'your-project-id',
    authDomain: 'your-project-id.firebaseapp.com',
    storageBucket: 'your-project-id.appspot.com',
    measurementId: 'G-XXXXXXXXXX',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDemoKeyUpdateWithYourProjectKey',
    appId: '1:123456789:android:abcdef0123456789abcdef',
    messagingSenderId: '123456789',
    projectId: 'your-project-id',
    storageBucket: 'your-project-id.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDemoKeyUpdateWithYourProjectKey',
    appId: '1:123456789:ios:abcdef0123456789abcdef',
    messagingSenderId: '123456789',
    projectId: 'your-project-id',
    storageBucket: 'your-project-id.appspot.com',
    iosBundleId: 'com.example.sectionTwoSupermarket',
  );
}
