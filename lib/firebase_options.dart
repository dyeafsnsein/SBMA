// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        return macos;
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyD6psRBdy7NLXJZFXhXIlCO9XpVzZ33T80',
    appId: '1:887942192043:web:cf969fc5679a1ca19250ee',
    messagingSenderId: '887942192043',
    projectId: 'sbma-79ac0',
    authDomain: 'sbma-79ac0.firebaseapp.com',
    storageBucket: 'sbma-79ac0.firebasestorage.app',
    measurementId: 'G-193X2P8V1L',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAWEixhLCwJnS2nD2uthXtBqhr7HcKEa1s',
    appId: '1:887942192043:android:9eee88afcfa4fd2b9250ee',
    messagingSenderId: '887942192043',
    projectId: 'sbma-79ac0',
    storageBucket: 'sbma-79ac0.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDU9AL2Q0fNLk79GGIbAgRooqkwN5fleIo',
    appId: '1:887942192043:ios:85b0d9377cb79a2d9250ee',
    messagingSenderId: '887942192043',
    projectId: 'sbma-79ac0',
    storageBucket: 'sbma-79ac0.firebasestorage.app',
    iosBundleId: 'com.example.testApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDU9AL2Q0fNLk79GGIbAgRooqkwN5fleIo',
    appId: '1:887942192043:ios:85b0d9377cb79a2d9250ee',
    messagingSenderId: '887942192043',
    projectId: 'sbma-79ac0',
    storageBucket: 'sbma-79ac0.firebasestorage.app',
    iosBundleId: 'com.example.testApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD6psRBdy7NLXJZFXhXIlCO9XpVzZ33T80',
    appId: '1:887942192043:web:2759d355328653989250ee',
    messagingSenderId: '887942192043',
    projectId: 'sbma-79ac0',
    authDomain: 'sbma-79ac0.firebaseapp.com',
    storageBucket: 'sbma-79ac0.firebasestorage.app',
    measurementId: 'G-L2L6FERSEL',
  );
}
