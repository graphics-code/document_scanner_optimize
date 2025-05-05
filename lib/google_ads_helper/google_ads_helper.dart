import 'dart:developer';
import 'dart:io';

import 'package:doc_scanner/main.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-9877635475483541/5655684143';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-9877635475483541/5116584052';
    } else {
      throw UnsupportedError("unsupported Platform");
    }
  }

  // IOS App Id
  //ca-app-pub-9877635475483541~3065135787

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-9877635475483541/7304641889';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-9877635475483541/6046522341';
    } else {
      throw UnsupportedError("unsupported Platform");
    }
  }
}

void createInterstitialAd() {
  InterstitialAd.load(
    adUnitId: AdHelper.interstitialAdUnitId,
    request: AdRequest(),
    adLoadCallback: InterstitialAdLoadCallback(
      onAdLoaded: (InterstitialAd ad) {
        print("sonar bal load hoiche");
        log('${ad.runtimeType} loaded.');
        interstitialReady = true;
        interstitialReadyNotifier.value = true;
        myInterstitial = ad;
      },
      onAdFailedToLoad: (LoadAdError error) {
        log('InterstitialAd failed to load: $error.');
        myInterstitial = null;
      },
    ),
  );
}

void finish(BuildContext context, [Object? result]) {
  if (Navigator.canPop(context)) Navigator.pop(context, result);
}

void showInterstitialAd(BuildContext context) async {
  if (myInterstitial == null) {
    log('attempt to show interstitial before loaded.');
    finish(context);
    return;
  }

  myInterstitial!.fullScreenContentCallback = FullScreenContentCallback(
    onAdShowedFullScreenContent: (InterstitialAd ad) =>
        print('ad onAdShowedFullScreenContent.'),
    onAdClicked: (ad) {
      interstitialReady = false;
      interstitialReadyNotifier.value = false;
    },
    onAdDismissedFullScreenContent: (InterstitialAd ad) {
      log('$ad onAdDismissedFullScreenContent.');
      interstitialReadyNotifier.value = false;
      interstitialReady = false;

      myInterstitial!.dispose();
    },
    onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
      log('$ad onAdFailedToShowFullScreenContent: $error');
      interstitialReadyNotifier.value = false;
      interstitialReady = false;
      myInterstitial!.dispose();
    },
  );
  myInterstitial!.show();
}
