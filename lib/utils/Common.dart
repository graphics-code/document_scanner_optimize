// const EDIT = 1;
// const INSTRAGRAM = 2;
// const TWITTER = 3;
// const LINKLEDIN = 4;
// const FACEBOOK = 5;

import 'package:doc_scanner/utils/addHelper.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

import '../main.dart';

const PLAY_STORE_LINK =
    "https://play.google.com/store/apps/details?id=com.photosocialcollage";
const APP_STORE_LINK =
    "https://apps.apple.com/us/app/pic-collage-maker-photo-frame/id1586019017";
Future<void> launchInBrowser(String url) async {
  if (await canLaunch(url)) {
    await launch(
      url,
      forceSafariVC: false,
      forceWebView: false,
      headers: <String, String>{'my_header_key': 'my_header_value'},
    );
  } else {
    throw 'Could not launch $url';
  }
}

extension IntExt on int {
  Size get size => Size(this.toDouble(), this.toDouble());
}

String get getBannerAdId => AdHelper.directoryViewBannerAdUnitId;

String get getInterstitialId => AdHelper.interstitialAdUnitId;

void createInterstitialAd({String? adUnitId, bool forceReload = false}) {
  // Keep already-loaded ad (needed after Document Files export -> Home).
  if (!forceReload && myInterstitial != null && interstitialReady) {
    return;
  }

  try {
    myInterstitial?.dispose();
  } catch (_) {}
  myInterstitial = null;
  interstitialReady = false;
  interstitialReadyNotifier.value = false;

  InterstitialAd.load(
    adUnitId: adUnitId ?? AdHelper.interstitialAdUnitId,
    request: const AdRequest(),
    adLoadCallback: InterstitialAdLoadCallback(
      onAdLoaded: (InterstitialAd ad) {
        log('${ad.runtimeType} loaded.');
        interstitialReady = true;
        interstitialReadyNotifier.value = true;
        myInterstitial = ad;
      },
      onAdFailedToLoad: (LoadAdError error) {
        log('InterstitialAd failed to load: $error.');
        myInterstitial = null;
        interstitialReady = false;
        interstitialReadyNotifier.value = false;
      },
    ),
  );
}

void showInterstitialAd(BuildContext context) {
  if (myInterstitial == null || !interstitialReady) {
    log('attempt to show interstitial before loaded.');
    return;
  }

  myInterstitial!.fullScreenContentCallback = FullScreenContentCallback(
    onAdShowedFullScreenContent: (InterstitialAd ad) =>
        log('ad onAdShowedFullScreenContent.'),
    onAdClicked: (ad) {
      interstitialReady = false;
      interstitialReadyNotifier.value = false;
    },
    onAdDismissedFullScreenContent: (InterstitialAd ad) {
      log('$ad onAdDismissedFullScreenContent.');
      try {
        ad.dispose();
      } catch (_) {}
      myInterstitial = null;
      interstitialReady = false;
      interstitialReadyNotifier.value = false;
      createInterstitialAd(); // preload next
    },
    onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
      log('$ad onAdFailedToShowFullScreenContent: $error');
      try {
        ad.dispose();
      } catch (_) {}
      myInterstitial = null;
      interstitialReady = false;
      interstitialReadyNotifier.value = false;
      createInterstitialAd(); // preload next
    },
  );

  interstitialReady = false;
  interstitialReadyNotifier.value = false;
  myInterstitial!.show();
}
