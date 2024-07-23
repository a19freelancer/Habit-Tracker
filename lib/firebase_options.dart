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
    apiKey: 'AIzaSyApgXwyJ_4NN8uVBtTrASWXncfciUc4lPU',
    appId: '1:703757732357:web:a05eea8c8d4f50d76bea6c',
    messagingSenderId: '703757732357',
    projectId: 'louki-1d00e',
    authDomain: 'louki-1d00e.firebaseapp.com',
    storageBucket: 'louki-1d00e.appspot.com',
    measurementId: 'G-XS14GM57DV',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAWl17frWu-lNf0DsXDV1WQ-AIU-pioPfY',
    appId: '1:703757732357:android:bd035a634e2138066bea6c',
    messagingSenderId: '703757732357',
    projectId: 'louki-1d00e',
    storageBucket: 'louki-1d00e.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDZaw7JYXm_OEmm6fAQ-mE1E3_gYGk3CNg',
    appId: '1:703757732357:ios:cf4fee5535d9694b6bea6c',
    messagingSenderId: '703757732357',
    projectId: 'louki-1d00e',
    storageBucket: 'louki-1d00e.appspot.com',
    androidClientId: '703757732357-7jajoprp70jundb2hvgte7i663afq78u.apps.googleusercontent.com',
    iosClientId: '703757732357-0qilb9b573he8vdqq93317vqdqoaiff2.apps.googleusercontent.com',
    iosBundleId: 'com.example.habitTrack',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDZaw7JYXm_OEmm6fAQ-mE1E3_gYGk3CNg',
    appId: '1:703757732357:ios:cf4fee5535d9694b6bea6c',
    messagingSenderId: '703757732357',
    projectId: 'louki-1d00e',
    storageBucket: 'louki-1d00e.appspot.com',
    androidClientId: '703757732357-7jajoprp70jundb2hvgte7i663afq78u.apps.googleusercontent.com',
    iosClientId: '703757732357-0qilb9b573he8vdqq93317vqdqoaiff2.apps.googleusercontent.com',
    iosBundleId: 'com.example.habitTrack',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyApgXwyJ_4NN8uVBtTrASWXncfciUc4lPU',
    appId: '1:703757732357:web:75b05e697eb4ccfc6bea6c',
    messagingSenderId: '703757732357',
    projectId: 'louki-1d00e',
    authDomain: 'louki-1d00e.firebaseapp.com',
    storageBucket: 'louki-1d00e.appspot.com',
    measurementId: 'G-3CYYGG4EDP',
  );

}