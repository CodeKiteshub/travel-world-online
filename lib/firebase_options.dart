import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web.',
      );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDCOUfdtjOn4O_YfA9-bBdLERFI-F_NOj0',
    appId: '1:934066571770:android:703ba20f189bf48dcebc43',
    messagingSenderId: '934066571770',
    projectId: 'travel-world-online',
    storageBucket: 'travel-world-online.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDPDV_y2R5sKKMN2iIr4bmjm_pQLZuSs-8',
    appId: '1:934066571770:ios:8da060edb449c280cebc43',
    messagingSenderId: '934066571770',
    projectId: 'travel-world-online',
    storageBucket: 'travel-world-online.appspot.com',
    iosClientId:
        '934066571770-4adp800kpo5hpq24fg71bta24el9h1cl.apps.googleusercontent.com',
    iosBundleId: 'com.travel.travelworldonline',
  );
}
