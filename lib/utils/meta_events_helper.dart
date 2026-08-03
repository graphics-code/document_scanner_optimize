import 'dart:developer';

import 'package:facebook_app_events/facebook_app_events.dart';

class MetaEventsHelper {
  MetaEventsHelper._();

  static final FacebookAppEvents _facebookAppEvents = FacebookAppEvents();

  static Future<void> initialize() async {
    try {
      // iOS ATT / advertiser tracking (also safe on Android)
      await _facebookAppEvents.setAdvertiserTracking(enabled: true);
      await _facebookAppEvents.setAutoLogAppEventsEnabled(true);
      await _facebookAppEvents.activateApp();
    } catch (e) {
      log('Meta SDK initialize failed: $e');
    }
  }

  static Future<void> logAppOpen() async {
    try {
      await _facebookAppEvents.logEvent(name: 'app_open');
    } catch (e) {
      log('Meta event app_open failed: $e');
    }
  }

  static Future<void> logPdfCreated() async {
    try {
      await _facebookAppEvents.logEvent(name: 'PDF_Created');
    } catch (e) {
      log('Meta event PDF_Created failed: $e');
    }
  }

  static Future<void> logPdfSigned() async {
    try {
      await _facebookAppEvents.logEvent(name: 'PDF_Signed');
    } catch (e) {
      log('Meta event PDF_Signed failed: $e');
    }
  }

  static Future<void> logPremiumPurchase({
    required double amount,
    String currency = 'USD',
  }) async {
    try {
      await _facebookAppEvents.logPurchase(
        amount: amount,
        currency: currency,
      );
    } catch (e) {
      log('Meta event Premium_Purchase failed: $e');
    }
  }
}
