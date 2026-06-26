// lib/firebase_options.dart
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
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDOkKOZ4DUBKpYOnC5jVjmIiGHgBxxOxeE',
    appId: '1:904947009914:web:15c3499406eff1e9616ec3',
    messagingSenderId: '904947009914',
    projectId: 'erp-project-8fc17',
    authDomain: 'erp-project-8fc17.firebaseapp.com',
    databaseURL: 'https://erp-project-8fc17-default-rtdb.firebaseio.com',
    storageBucket: 'erp-project-8fc17.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBV578FI-9RM3C52mK3esxfc40p-YmgErc',
    appId: '1:904947009914:android:6ea02dd2769b2928616ec3',
    messagingSenderId: '904947009914',
    projectId: 'erp-project-8fc17',
    databaseURL: 'https://erp-project-8fc17-default-rtdb.firebaseio.com',
    storageBucket: 'erp-project-8fc17.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBrDGRNN5FQGY2v0_FUrRbeNMrS80Uvuow',
    appId: '1:904947009914:ios:58b47f828e589e08616ec3',
    messagingSenderId: '904947009914',
    projectId: 'erp-project-8fc17',
    databaseURL: 'https://erp-project-8fc17-default-rtdb.firebaseio.com',
    storageBucket: 'erp-project-8fc17.firebasestorage.app',
    iosBundleId: 'com.example.erpFrontendProject',
  );
}