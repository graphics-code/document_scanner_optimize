import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'local_notification.dart';




class FirebaseMessagingService {
  FirebaseMessagingService._internal();
  static final FirebaseMessagingService _instance = FirebaseMessagingService._internal();
  factory FirebaseMessagingService.instance() => _instance;

  LocalNotificationsService? _localNotificationsService;

  Future<void> init({required LocalNotificationsService localNotificationsService}) async {
    _localNotificationsService = localNotificationsService;

    print('🔧 Initializing Firebase Messaging...');
    if (Platform.isIOS) {
      print('🍏 iOS platform detected. Push will only work on real devices.');
    }

    await _requestPermission();
    await _handlePushNotificationsToken();

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    print('✅ Background message handler registered');

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print('📩 Initial push message: ${initialMessage.data}');
      _onMessageOpenedApp(initialMessage);
    }

    print('✅ Firebase Messaging initialized');
  }

  Future<void> _handlePushNotificationsToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    print('📱 FCM Token: $token');

    final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    print('🔐 APNs Token: $apnsToken');
    if (apnsToken == null) {
      print('❗ APNs token is NULL. Push notifications will NOT work on iOS.');
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      print('🔄 FCM token refreshed: $newToken');
      // TODO: Send to your server if needed
    }).onError((e) {
      print('❌ Token refresh error: $e');
    });
  }

  Future<void> _requestPermission() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('🔔 iOS Notification permission: ${settings.authorizationStatus}');
    switch (settings.authorizationStatus) {
      case AuthorizationStatus.authorized:
        print('✅ User granted permission');
        break;
      case AuthorizationStatus.denied:
        print('❌ User denied permission');
        break;
      case AuthorizationStatus.notDetermined:
        print('❓ Permission not determined');
        break;
      case AuthorizationStatus.provisional:
        print('🟡 Provisional permission granted');
        break;
    }
  }

  void _onForegroundMessage(RemoteMessage message) {
    print('📬 Foreground message received');
    print('🔧 Data: ${message.data}');
    final notification = message.notification;
    if (notification != null) {
      print('🔔 Title: ${notification.title}');
      print('📝 Body: ${notification.body}');
      _localNotificationsService?.showNotification(
        notification.title,
        notification.body,
        message.data.toString(),
      );
    } else {
      print('⚠️ Message has no notification payload');
    }
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    print('📲 Notification tapped. Message: ${message.data}');
    // TODO: Navigate or handle message data
  }
}


@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📥 Background push received: ${message.messageId}');
  print('🔧 Data: ${message.data}');
}