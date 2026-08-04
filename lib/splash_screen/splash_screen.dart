import 'package:doc_scanner/core/local_storage.dart';
import 'package:doc_scanner/utils/app_assets.dart';
import 'package:doc_scanner/utils/firebase_messageing.dart';
import 'package:doc_scanner/utils/helper.dart';
import 'package:doc_scanner/utils/local_notification.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nb_utils/nb_utils.dart';
import '../bottom_bar/bottom_bar.dart';
import '../firebase_options.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initAndNavigate());
  }

  Future<void> _initAndNavigate() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await LocalStorage().init();
      await initialize();
      await AppHelper().createDirectories();
      MobileAds.instance.initialize();

      final localNotificationsService = LocalNotificationsService.instance();
      await localNotificationsService.init();
      final firebaseMessagingService = FirebaseMessagingService.instance();
      await firebaseMessagingService.init(
        localNotificationsService: localNotificationsService,
      );
    } catch (e, st) {
      debugPrint('Splash init error: $e\n$st');
    }

    if (!mounted) return;
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const BottomBar()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(""),
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(18)),
                child: Image.asset(
                  AppAssets.splashLogo,
                  height: 130,
                  width: 130,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 25.0),
                child: Text(
                  "SCAN FASTER, WORK SMARTER.",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
