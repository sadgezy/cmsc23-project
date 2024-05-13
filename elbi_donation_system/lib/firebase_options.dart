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
    apiKey: 'AIzaSyDccLP6Myi2Tja7piyXu11oGSGhkjZCMOg',
    appId: '1:91010568696:web:1dbfc97cf83de4e69b060d',
    messagingSenderId: '91010568696',
    projectId: 'elbi-donation-system-37957',
    authDomain: 'elbi-donation-system-37957.firebaseapp.com',
    storageBucket: 'elbi-donation-system-37957.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDU4rWt4AjuVhyR0sJ5da0Bx92P1p-BmQU',
    appId: '1:91010568696:android:c0a8e55b441c54429b060d',
    messagingSenderId: '91010568696',
    projectId: 'elbi-donation-system-37957',
    storageBucket: 'elbi-donation-system-37957.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDY6qsd1WE6jmLZ3aHQncrgxI7hdzYTTJI',
    appId: '1:91010568696:ios:ddf61f2a836ac27e9b060d',
    messagingSenderId: '91010568696',
    projectId: 'elbi-donation-system-37957',
    storageBucket: 'elbi-donation-system-37957.appspot.com',
    iosBundleId: 'com.example.elbiDonationSystem',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDY6qsd1WE6jmLZ3aHQncrgxI7hdzYTTJI',
    appId: '1:91010568696:ios:ddf61f2a836ac27e9b060d',
    messagingSenderId: '91010568696',
    projectId: 'elbi-donation-system-37957',
    storageBucket: 'elbi-donation-system-37957.appspot.com',
    iosBundleId: 'com.example.elbiDonationSystem',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDccLP6Myi2Tja7piyXu11oGSGhkjZCMOg',
    appId: '1:91010568696:web:014dcd78c35ff2599b060d',
    messagingSenderId: '91010568696',
    projectId: 'elbi-donation-system-37957',
    authDomain: 'elbi-donation-system-37957.firebaseapp.com',
    storageBucket: 'elbi-donation-system-37957.appspot.com',
  );
}
