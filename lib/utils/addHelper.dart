import 'dart:io';

class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isIOS) {
      return 'ca-app-pub-9877635475483541/3626209183';
    } else {
      throw UnsupportedError("unsupported Platform");
    }
  }

  // IOS App Id
  //ca-app-pub-9877635475483541~3065135787

  static String get interstitialAdUnitId {
    if (Platform.isIOS) {
      return 'ca-app-pub-9877635475483541/7310836156';
    } else {
      throw UnsupportedError("unsupported Platform");
    }
  }
}
