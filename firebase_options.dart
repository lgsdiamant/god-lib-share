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
    apiKey: 'AIzaSyDvYi8kQ96BKS-rNAMzZ9WoNci8jJ_WQJQ',
    appId: '1:1016954140202:web:af16e45e50443b87b3f553',
    messagingSenderId: '1016954140202',
    projectId: 'godofdebate-93601',
    authDomain: 'godofdebate-93601.firebaseapp.com',
    storageBucket: 'godofdebate-93601.firebasestorage.app',
    measurementId: 'G-JMVP86BH0C',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBBB-eqi6ITXHSMf6qslzj8W2Ux_wdJFmc',
    appId: '1:1016954140202:android:2436f1d3e338c8f8b3f553',
    messagingSenderId: '1016954140202',
    projectId: 'godofdebate-93601',
    storageBucket: 'godofdebate-93601.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAjWgB9fV_eDxOY-LQPTRxcG_oVB5tEY3I',
    appId: '1:1016954140202:ios:46bfddc5ba3f5825b3f553',
    messagingSenderId: '1016954140202',
    projectId: 'godofdebate-93601',
    storageBucket: 'godofdebate-93601.firebasestorage.app',
    iosBundleId: 'com.lgsdiamant.godofdebate',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAjWgB9fV_eDxOY-LQPTRxcG_oVB5tEY3I',
    appId: '1:1016954140202:ios:46bfddc5ba3f5825b3f553',
    messagingSenderId: '1016954140202',
    projectId: 'godofdebate-93601',
    storageBucket: 'godofdebate-93601.firebasestorage.app',
    iosBundleId: 'com.lgsdiamant.godofdebate',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDvYi8kQ96BKS-rNAMzZ9WoNci8jJ_WQJQ',
    appId: '1:1016954140202:web:9ff470494399b08db3f553',
    messagingSenderId: '1016954140202',
    projectId: 'godofdebate-93601',
    authDomain: 'godofdebate-93601.firebaseapp.com',
    storageBucket: 'godofdebate-93601.firebasestorage.app',
    measurementId: 'G-DQXGDSB03Y',
  );

}