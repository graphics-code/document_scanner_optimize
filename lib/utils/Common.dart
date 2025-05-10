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

String get getBannerAdId => AdHelper.bannerAdUnitId;

String get getInterstitialId => AdHelper.interstitialAdUnitId;

void createInterstitialAd() {
  InterstitialAd.load(
    adUnitId: AdHelper.interstitialAdUnitId,
    request: AdRequest(),
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
      },
    ),
  );
}

void showInterstitialAd(BuildContext context) {
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
