import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCa0zONXU2owYw8ZEWUbagn6VF_UsjqGnA',
    appId: '1:961435398392:web:170040999557e8a05f8b0d',
    messagingSenderId: '961435398392',
    projectId: 'flutter-epi-sousse',
    authDomain: 'flutter-epi-sousse.firebaseapp.com',
    storageBucket: 'flutter-epi-sousse.firebasestorage.app',
    measurementId: 'G-293W56HPT2',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBn0olXhx5kKsvTieB1SVOPhYzMjRFdBqU',
    appId: '1:961435398392:android:04acd720c3333c515f8b0d',
    messagingSenderId: '961435398392',
    projectId: 'flutter-epi-sousse',
    storageBucket: 'flutter-epi-sousse.firebasestorage.app',
  );
}
